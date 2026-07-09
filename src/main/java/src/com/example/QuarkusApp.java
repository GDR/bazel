package com.example;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import org.jboss.logging.Logger;

@Path("/hello")
public class QuarkusApp {

    private static final Logger logger = Logger.getLogger(QuarkusApp.class);

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String hello() {
        logger.info("Hello endpoint called!");
        return "Hello from hermetic Quarkus in Bazel 9 & Nix!\n";
    }
}
