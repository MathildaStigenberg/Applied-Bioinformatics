task hello_world {
    String name = "World"
    command {
        echo 'Hello, ${name}'
    }
    output {
        File out = stdout()
    }
    runtime {
        docker: 'ubuntu:latest'
    }
}

workflow hello {
    call hello_world
}