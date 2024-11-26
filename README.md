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

then, with the cursor on the comment, run ```NvimLlm```

this will fire off a request via the rust tool in the repo, parse the response, and write it below the comment.
