#!/bin/bash
clear
pkill -f ws-epro
echo INSTALANDO NOVO WS-EPRO
sleep 1
cd

#Install ws-epro
wget -q --show-progress --load-cookies /tmp/cookies.txt "https://www.dropbox.com/home?preview=ws-epro?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://www.dropbox.com/scl/fi/xnqtou1khrscq46bvsnyi/ws-epro?rlkey=fvu3i0jjpbat8o5saixkmajp8&dl=0' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1IbwfNpKpa1JzvXsDT-WgNpp5nWrklisG" -O /usr/local/bin/ws-epro && rm -rf /tmp/cookies.txt
chmod +x /usr/local/bin/ws-epro

#ws-epro service
wget -q --show-progress --load-cookies /tmp/cookies.txt "https://www.dropbox.com/home?preview=ws-epro.service?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://www.dropbox.com/scl/fi/6oog8t0t70zz087pojq50/ws-epro.service?rlkey=d9hpooqs0u36dhd9j4sym69ps&dl=0' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=10hGKYNZUMHdr4y-ZxMr0wKQpj9zSQRkZ" -O /etc/systemd/system/ws-epro.service && rm -rf /tmp/cookies.txt
chmod +x /etc/systemd/system/ws-epro.service

#ws-epro port
wget -q --show-progress --load-cookies /tmp/cookies.txt "https://www.dropbox.com/home?preview=port?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://www.dropbox.com/scl/fi/i1a0sthwuncxg38r5zl3g/port?rlkey=m7cu2w3vh18p3nbxvc3kql3rc&dl=0' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1h9QvOnXScplGTnfpbJ7KJDn4CDkwUKWa" -O /usr/bin/ws-port && rm -rf /tmp/cookies.txt
chmod +x /usr/bin/ws-port

#seting port
clear
echo SELECIONE PORTAS
sleep 1
read -p "PORTA LOCAL : " openssh
read -p "PORTA PHYTON : " wsopenssh
WS_DIR=/usr/local/etc/ws-epro
if [ -d "$WS_DIR" ]; then # if it exists,delete it.
    rm -rf "$WS_DIR"
fi
mkdir "$WS_DIR"
echo "CONFIGURANDO SERVIDOR ESPERE..."
sleep 0.5
echo "# verbose level 0=info, 1=verbose, 2=very verbose" >> /usr/local/etc/ws-epro/config.yml
echo "verbose: 0" >> /usr/local/etc/ws-epro/config.yml
echo "listen:"  >> /usr/local/etc/ws-epro/config.yml

#seting port
echo "##openssh" >> /usr/local/etc/ws-epro/config.yml
echo "- target_host: 127.0.0.1" >> /usr/local/etc/ws-epro/config.yml
echo "##portopenssh" >> /usr/local/etc/ws-epro/config.yml
echo "  target_port: $openssh" >> /usr/local/etc/ws-epro/config.yml
echo "##wsopenssh" >> /usr/local/etc/ws-epro/config.yml
echo "  listen_port: $wsopenssh" >> /usr/local/etc/ws-epro/config.yml

chmod +x /usr/local/etc/ws-epro/config.yml

#Enable & Start service
systemctl enable ws-epro
systemctl start ws-epro

echo "CONFIGURE SEU SERVIDOR WEBSOCKET PRO..."
sleep 0.3
clear
LP='\033[1;35m'
NC='\033[0m' # No Color
echo -e "${LP}"
echo    "
░██╗░░░░░░░██╗░██████╗░░░░░░██████╗░██████╗░░█████╗░
░██║░░██╗░░██║██╔════╝░░░░░░██╔══██╗██╔══██╗██╔══██╗
░╚██╗████╗██╔╝╚█████╗░█████╗██████╔╝██████╔╝██║░░██║
░░████╔═████║░░╚═══██╗╚════╝██╔═══╝░██╔══██╗██║░░██║
░░╚██╔╝░╚██╔╝░██████╔╝░░░░░░██║░░░░░██║░░██║╚█████╔╝
░░░╚═╝░░░╚═╝░░╚═════╝░░░░░░░╚═╝░░░░░╚═╝░░╚═╝░╚════╝░"

echo    "💙SCRIPT WEBSOCKET CLOUDFLARE SEM PRO E-PRO💙"
echo    "Creditos A : @TURBONET2023"
echo    "════💙🧑🏽‍💻EDITADO POR THEFATHER12🧑🏽‍💻💙════"
echo    "╔════════════════════╗"
echo    "   Porta Local SSH: $openssh"
echo    "   Porta Phyton: $wsopenssh"
echo    "╚════════════════════╝"
echo    ""
echo    "WEBSOCKET SEM SER UM PLANO PRO CLOUDFLARE"
echo    "---------------------------------------"
echo    ""
echo    "PARA ALTERAR O COMANDO DE USO DA PORTA: ws-port"
echo    "---------------------------------------"
echo    ""
echo    "GET / HTTP/1.1[crlf]Host: Dominio[crlf]Upgrade: websocket[crlf][crlf]"
echo    "---------------------------------------"
echo -e "${NC}"
rm -rf install-ws && cat /dev/null > ~/.bash_history && history -c
echo -e "\033[01;31m\033[1;33mPARA INICIAR DIGITE: \033[1;32mmenu\033[0m" 
