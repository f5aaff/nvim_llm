use clap::Parser;
use futures_util::StreamExt;
use reqwest::Client;
use serde::{Deserialize, Serialize};
use serde_json::de::Deserializer;
use std::fs;

#[derive(Parser, Debug)]
#[command(author, version, about)]
struct Args {
    #[arg(short, long, default_value = "config.json")]
    config: String,

    #[arg(short, long, default_value = "")]
    msg: String,
}

#[derive(Deserialize)]
struct Config {
    model: String,
    address: String,
    preamble: String
}

#[derive(Serialize)]
struct RequestBody<'a> {
    model: &'a str,
    prompt: &'a str,
}

#[derive(Serialize, Deserialize)]
struct ResponseBody {
    response: String,
    done: bool,
}

async fn send_request(config: &Config, message: &str) -> Result<String, anyhow::Error> {
    // Prepare the initial request body
    let preamble = config.preamble.to_owned();
    let rambled_message = preamble+" REQUEST: "+message;

    let reqbody = RequestBody {
        model: &config.model,
        prompt: &rambled_message,
    };

    let body = serde_json::to_string(&reqbody)?;
    let client = Client::new();

    let response = client.post(&config.address).body(body).send().await?;

    // Check if the request was successful
    if !response.status().is_success() {
        let error_body = response
            .text()
            .await
            .unwrap_or_else(|_| "Failed to read error body".to_string());
        return Err(anyhow::anyhow!("Request failed:{}", error_body));
    }

    let mut full_response = String::new();
    let mut buffer = Vec::new();

    // Stream the response body in chunks and process each chunk incrementally
    let mut stream = response.bytes_stream();

    while let Some(chunk) = stream.next().await {
        let chunk = chunk?;
        buffer.extend_from_slice(&chunk);

        // Try to parse JSON objects from the current buffer
        let mut deserializer = Deserializer::from_slice(&buffer).into_iter::<ResponseBody>();

        // Parse all JSON objects in the current buffer
        while let Some(parsed) = deserializer.next() {
            match parsed {
                Ok(api_response) => {
                    full_response.push_str(&api_response.response); // Preserve the response content
                    if api_response.done {
                        return Ok(full_response); // Stop when 'done' is true
                    }
                }
                Err(e) => {
                    // If there's an error, continue accumulating data
                    eprintln!("Error parsing JSON object: {}", e);
                }
            }
        }

        // After parsing, clean up the buffer to remove the processed data
        let remaining_data = deserializer.byte_offset();
        buffer.drain(0..remaining_data);
    }

    Ok(full_response)
}

fn load_config(path: &str) -> Result<Config, std::io::Error> {
    let config_str = fs::read_to_string(path)?;
    let config: Config = serde_json::from_str(&config_str)?;
    Ok(config)
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let args = Args::parse();
    let config = load_config(&args.config)?;
    let message = args.msg;

    let response = send_request(&config, &message).await?;

    println!("{}", response);
    Ok(())
}
