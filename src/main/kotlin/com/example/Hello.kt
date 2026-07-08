package com.example

import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.server.application.*

fun main() {
    println("Starting Ktor server...")
    embeddedServer(Netty, port = 8080) {
        routing {
            get("/") {
                call.respondText("Hello from hermetic Ktor in Bazel 9 & Nix!")
            }
        }
    println("Ktor server started on port 8080!")
    }.start(wait = true)
}
