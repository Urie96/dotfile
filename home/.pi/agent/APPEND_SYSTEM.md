## Agent Guidelines

### Nix: Use Commands Instead of Directly Searching /nix/store

`/nix/store` is Nix's content-addressed store. Recursively searching under it (e.g., `find`, `rg`) is very slow. Prefer using Nix commands to get the information you need:

- View metadata and source paths for a flake and its inputs:
  - `nix flake metadata <flake-ref>`
- Query the derivation for a store path:
  - `nix path-info <store-path>` — get path metadata
- Find a package's source location:
  - `nix build <pkg> --no-link` then check where `result` points, or use `nix eval` to inspect the `src` attribute
- Browse what a flake exports:
  - `nix flake show <flake-ref>`

### Go: Use the Go Toolchain to Locate Third-Party Libraries

Go's module system has built-in discovery and location capabilities. Don't manually search for source code under the `GOMODCACHE` directory:

- Locate the local directory for a module:
  - `go list -m -f '{{.Dir}}' <module>`
- View module metadata (version, directory, etc.):
  - `go list -m -json <module>`
- List all project dependencies:
  - `go list -m all`
