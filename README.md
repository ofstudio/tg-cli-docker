# tg-cli-docker
Runs [pataquets/telegram-cli](https://hub.docker.com/r/pataquets/telegram-cli/) Docker image in detached mode via Docker Machine.


## Usage
1. Setup [Docker](https://docs.docker.com) and [Docker Machine](https://docs.docker.com/machine/)
2. Run `tg-cli.sh docker_machine_name account_name`. 
3. Enter login credentials (phone, code, password) if needed
4. Send test message this account: it should appear in the console.
5. Type `^C` to close login stage and run daemon stage (detached mode).
6. Docker container and credentials volume folder will be named based on `account_name` specified on step 2.

## Connect to container
Run `docker attach tg_cli_account_name` to open `telegram-cli` shell (use actual container name instead of `tg_cli_account_name`). Then type `status_online` for example to set status online permanently. Type `^D` to close session. 

## License
MIT
