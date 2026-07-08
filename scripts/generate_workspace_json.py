#!/usr/bin/env python3
import os
import json
import subprocess
import sys

def main():
    # Determine the workspace root
    script_dir = os.path.dirname(os.path.abspath(__file__))
    workspace_root = os.path.dirname(script_dir)
    os.chdir(workspace_root)

    print(f"Workspace root: {workspace_root}")

    # Run the classpath script to get all JAR files
    classpath_script = os.path.join(script_dir, "kls-classpath")
    if not os.path.exists(classpath_script):
        print(f"Error: {classpath_script} not found", file=sys.stderr)
        sys.exit(1)

    try:
        output = subprocess.check_output([classpath_script], text=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running classpath script: {e}", file=sys.stderr)
        sys.exit(1)

    jars = [line.strip() for line in output.splitlines() if line.strip().endswith(".jar") and not line.strip().endswith("-sources.jar")]
    print(f"Found {len(jars)} class JAR dependencies.")

    # Build the libraries list and module dependencies list
    libraries = []
    dependencies = [
        {"type": "inheritedSdk"},
        {"type": "moduleSource"}
    ]

    for idx, jar_path in enumerate(jars):
        if not os.path.exists(jar_path):
            # Try to resolve symlinks or skip if non-existent
            continue

        lib_name = f"library_{idx}_{os.path.basename(jar_path)}"
        
        # Library definition
        roots = [
            {
                "path": jar_path,
                "type": "CLASSES",
                "inclusionOptions": "root_itself"
            }
        ]
        
        sources_jar = jar_path.replace(".jar", "-sources.jar")
        if os.path.exists(sources_jar):
            roots.append({
                "path": sources_jar,
                "type": "SOURCES",
                "inclusionOptions": "root_itself"
            })

        lib_data = {
            "name": lib_name,
            "type": None,
            "level": "project",
            "roots": roots,
            "excludedRoots": []
        }
        libraries.append(lib_data)

        # Dependency in module
        dep_data = {
            "type": "library",
            "name": lib_name,
            "scope": "compile",
            "isExported": False
        }
        dependencies.append(dep_data)

    # Source roots detection
    source_roots = []
    java_src = os.path.join(workspace_root, "src/main/java")
    if os.path.exists(java_src):
        source_roots.append({
            "path": java_src,
            "type": "java-source"
        })

    kotlin_src = os.path.join(workspace_root, "src/main/kotlin")
    if os.path.exists(kotlin_src):
        source_roots.append({
            "path": kotlin_src,
            "type": "kotlin-source"
        })

    # Module definition
    module = {
        "name": "bazel-module",
        "type": "JAVA_MODULE",
        "dependencies": dependencies,
        "contentRoots": [
            {
                "path": workspace_root,
                "excludedPatterns": [],
                "excludedUrls": [],
                "sourceRoots": source_roots
            }
        ],
        "facets": []
    }

    # Entire Workspace Data structure
    workspace_data = {
        "modules": [module],
        "libraries": libraries
    }

    # Write to workspace.json
    output_file = os.path.join(workspace_root, "workspace.json")
    with open(output_file, "w") as f:
        json.dump(workspace_data, f, indent=4)

    print(f"Successfully generated {output_file} with {len(libraries)} libraries.")

if __name__ == "__main__":
    main()
