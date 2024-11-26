# nvim_llm

this serves as a simple tool to make requests to a locally running ollama serve instance.


start the server, by running:
```bash
   ollama serve
```

you can add env. vars to help if you wish:

```bash
OLLAMA_HOST=0.0.0.0:8080 OLLAMA_MODELS=/usr/share/ollama/.ollama/models ollama serve
```

the above example will match the defaults in the example config.

whilst in vim, make a comment in a file:


```go
package main

import "fmt"

func main() {
    fmt.Println("hello world!")

    //for loop in go, printing from 1 to 10
}
```

then, with the cursor on the comment, run ```LlamaComp```

this will fire off a request via the rust tool in the repo, parse the response, and write it below the comment.


# nvim_llm_tool

this is a simple rust package, takes some command line args that get called by the plugin.
```
Usage: nvim_llm [OPTIONS]

Options:
  -c, --config <CONFIG>  [default: config.json]
  -m, --msg <MSG>        [default: ]
  -h, --help             Print help
  -V, --version          Print version
  ```

the config looks like this:
```json
{
    "model": "codellama:latest",
    "address": "http://localhost:8080/api/generate",
    "preamble": "Respond with only the code snippet for the requested task. Do not include package declarations, import statements, or any extra text that is not part of the core code. If explanations are necessary, write them as inline comments in the code itself. Do not wrap the code in backticks, markdown,code block, or any other formatting."
}
```
