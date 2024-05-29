Requeriments :
+ tor
+ tsocks

```bash
sudo apt update -y; sudo apt install tor tsocks; sudo systemctl enable --now tor ; tsocks -on
```

Next we need to configure the Docker Proxy and apt proxy

```bash
vi /etc/systemd/system/docker.service.d/proxy.conf
```

```conf
[Service]
Enviroment="HTTP_PROXY=socks5://127.0.0.1:9050"
Enviroment="HTTPS_PROXY=socks5://127.0.0.1:9050"
```

```bash
vi /etc/apt/apt.conf.d/proxy.conf
```

```conf
Acquire::http::Proxy "socks5h://127.0.0.1:9050/";
```

Finally , we restart the docker service

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```