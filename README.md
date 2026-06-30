# Fusion-proxy

HTTP forward proxy для Autodesk Fusion 360.

Этот репозиторий разворачивает прокси-сервер: `mitmdump` в режиме passthrough, слушает порт 3128, пропускает трафик клиента к Autodesk.

Критичный endpoint для Fusion: `https://api.aps.autodesk.com/health`. Без него приложение не считает сеть рабочей.

![Network Diagnostic Test — успех](docs/images/network-diagnostic.png)

## Установка

```bash
git clone https://github.com/Rrisinglight/Fusion-proxy.git fusion-proxy
cd fusion-proxy
sudo ./scripts/install.sh
```

В моём случае соединение проходит только по IPv6 (APS отвечает только по v6), открытый порт TCP 3128.

В сетевых настройках Fusion указать прокси:

Override, Proxy Host — IP вашего сервера, Proxy Port — 3128

![Настройки сети Fusion](docs/images/fusion-network-settings.png)

Проверка: `./scripts/verify.sh`. Логи: `journalctl -u fusion-proxy -f`.

Подробности — [docs/deployment-guide.md](docs/deployment-guide.md).
