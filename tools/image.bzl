"""Helper macros for building and loading OCI images."""

load("@rules_pkg//pkg:tar.bzl", "pkg_tar")
load("@rules_oci//oci:defs.bzl", "oci_image", "oci_load")

def cc_image(name, binary, base = "@distroless_cc", repo_tags = None):
    """Builds a pkg_tar containing the binary, puts it in an oci_image, and sets up oci_load.

    Args:
      name: The name of the oci_load target.
      binary: The target label of the C++ binary to package.
      base: The base image to build on top of.
      repo_tags: The tags to assign to the loaded image.
    """
    tar_name = name + "_tar"
    image_name = name + "_img"
    
    pkg_tar(
        name = tar_name,
        srcs = [binary],
        package_dir = "/app",
    )
    
    # Extract binary name from label (e.g., ":hello" -> "hello")
    binary_name = binary.split(":")[-1]
    
    oci_image(
        name = image_name,
        base = base,
        tars = [":" + tar_name],
        entrypoint = ["/app/" + binary_name],
    )
    
    oci_load(
        name = name,
        image = ":" + image_name,
        repo_tags = repo_tags or [name + ":latest"],
    )

def jvm_image(name, deploy_jar, base = "@distroless_java", repo_tags = None):
    """Builds a pkg_tar containing the deploy jar, puts it in an oci_image, and sets up oci_load for Java.

    Args:
      name: The name of the oci_load target.
      deploy_jar: The target label of the deployable Java JAR to package.
      base: The base Java image to build on top of.
      repo_tags: The tags to assign to the loaded image.
    """
    tar_name = name + "_tar"
    image_name = name + "_img"
    
    pkg_tar(
        name = tar_name,
        srcs = [deploy_jar],
        package_dir = "/app",
    )
    
    # Extract jar name from label (e.g., ":main_deploy.jar" -> "main_deploy.jar")
    jar_name = deploy_jar.split(":")[-1]
    
    oci_image(
        name = image_name,
        base = base,
        tars = [":" + tar_name],
        entrypoint = [
            "java",
            "-jar",
            "/app/" + jar_name,
        ],
    )
    
    oci_load(
        name = name,
        image = ":" + image_name,
        repo_tags = repo_tags or [name + ":latest"],
    )

def quarkus_image(name, srcs, base = "@distroless_java", repo_tags = None):
    """Builds a pkg_tar containing Quarkus application files, puts it in an oci_image, and sets up oci_load.

    Args:
      name: The name of the oci_load target.
      srcs: The list of sources/files to package (e.g. pkg_files target).
      base: The base Java image to build on top of.
      repo_tags: The tags to assign to the loaded image.
    """
    tar_name = name + "_tar"
    image_name = name + "_img"
    
    pkg_tar(
        name = tar_name,
        srcs = srcs,
    )
    
    oci_image(
        name = image_name,
        base = base,
        tars = [":" + tar_name],
        env = {
            "QUARKUS_APP": "/app",
        },
        entrypoint = [
            "java",
            "-Djava.util.logging.manager=org.jboss.logmanager.LogManager",
            "-cp",
            "/app/lib/boot/*:/app/lib/main/*",
            "io.quarkus.bootstrap.runner.QuarkusEntryPoint",
        ],
    )
    
    oci_load(
        name = name,
        image = ":" + image_name,
        repo_tags = repo_tags or [name + ":latest"],
    )

def go_image(name, binary, base = "@distroless_cc", repo_tags = None):
    """Builds a pkg_tar containing the Go binary, puts it in an oci_image, and sets up oci_load.

    Args:
      name: The name of the oci_load target.
      binary: The target label of the Go binary to package.
      base: The base image to build on top of.
      repo_tags: The tags to assign to the loaded image.
    """
    tar_name = name + "_tar"
    image_name = name + "_img"
    
    pkg_tar(
        name = tar_name,
        srcs = [binary],
        package_dir = "/app",
    )
    
    # Extract binary name from label (e.g., ":hello_go" -> "hello_go")
    binary_name = binary.split(":")[-1]
    
    oci_image(
        name = image_name,
        base = base,
        tars = [":" + tar_name],
        entrypoint = ["/app/" + binary_name],
    )
    
    oci_load(
        name = name,
        image = ":" + image_name,
        repo_tags = repo_tags or [name + ":latest"],
    )

def rust_image(name, binary, base = "@distroless_cc", repo_tags = None):
    """Builds a pkg_tar containing the Rust binary, puts it in an oci_image, and sets up oci_load.

    Args:
      name: The name of the oci_load target.
      binary: The target label of the Rust binary to package.
      base: The base image to build on top of.
      repo_tags: The tags to assign to the loaded image.
    """
    tar_name = name + "_tar"
    image_name = name + "_img"
    
    pkg_tar(
        name = tar_name,
        srcs = [binary],
        package_dir = "/app",
    )
    
    # Extract binary name from label (e.g., ":hello_rust" -> "hello_rust")
    binary_name = binary.split(":")[-1]
    
    oci_image(
        name = image_name,
        base = base,
        tars = [":" + tar_name],
        entrypoint = ["/app/" + binary_name],
    )
    
    oci_load(
        name = name,
        image = ":" + image_name,
        repo_tags = repo_tags or [name + ":latest"],
    )




