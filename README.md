# Pterodactyl Enshrouded Proton

A reproducible Pterodactyl runtime and egg for the Windows-only Enshrouded dedicated server.

The upstream Pterodactyl Enshrouded egg currently uses a Debian Bookworm Proton image. Enshrouded 1.0 introduced a Steamworks runtime requirement that failed there with `No SteamUtils011`. This image moves the runtime to Ubuntu 24.04 (glibc 2.39) and pins GE-Proton 11-9 with a SHA-512 checksum.

The entrypoint also exports the Steam compatibility app ID explicitly. GE-Proton 11 can otherwise leave a fresh prefix waiting in its Steam launch shim before the Enshrouded executable is mapped.

## Compatibility

Validated on 15 October 2026 with:

- Enshrouded Dedicated Server Steam App ID `2278520`
- Steam build `25936466`
- Enshrouded Game Version SVN `1265863`
- GE-Proton `11-9`
- Pterodactyl Panel `1.15.1`
- Wings `1.12.1`
- Linux `amd64`

The container is published as:

```text
ghcr.io/cappyredbeard/pterodactyl-enshrouded-proton:stable
```

Versioned Git tags also produce matching image tags. Commit builds receive a `sha-...` tag for rollback.

## Install the egg

1. Download [`egg-enshrouded-proton.json`](./egg-enshrouded-proton.json).
2. In Pterodactyl, import it into the desired nest.
3. Create a server from the imported egg and configure its four user-group passwords.
4. Allocate the query/game port as both TCP and UDP.

For an existing server, take a verified backup before changing its egg or Docker image. Selecting the new image does not itself alter the mounted server data, but the next Enshrouded startup may migrate save data to a newer game format.

## Updates

`AUTO_UPDATE=1` makes SteamCMD update Enshrouded whenever the container starts. Set it to `0` when you need a controlled maintenance window. `VALIDATE=1` additionally validates the Steam installation and increases startup time.

The `stable` image tag changes only when this repository publishes a new default-branch build. GE-Proton is deliberately pinned rather than downloaded dynamically, so a new Proton release cannot silently change the runtime.

## Existing saves

Enshrouded 1.0 can migrate older rotating save files to `world0.ksd`. Back up the entire `savegame` directory and the server configuration before the first upgraded start. Do not delete the older save generations until the migrated world has been tested.

## Troubleshooting

A healthy startup should include:

```text
[Session] 'HostOnline' (up)!
```

Also verify that the container remains running, the allocated UDP port is bound, and the server registers with Steam. Container status by itself is not a complete readiness check.

If an update fails:

1. Stop the server.
2. Preserve the complete server volume and logs.
3. Select a previously working `sha-...` or versioned image tag.
4. Restore save data only if Enshrouded changed it and the migrated copy is unusable.

## Provenance

The egg and SteamCMD behavior are derived from the MIT-licensed [Ptero-Eggs Enshrouded egg](https://github.com/pterodactyl/game-eggs/tree/main/enshrouded) and [Ptero-Eggs SteamCMD Proton image](https://github.com/ptero-eggs/yolks/tree/main/steamcmd/proton). GE-Proton is downloaded from its [official release repository](https://github.com/GloriousEggroll/proton-ge-custom/releases).

## License

MIT. See [`LICENSE`](./LICENSE).
