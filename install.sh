#!/bin/bash

# Verificar se o proxy já está instalado
if [ -f /usr/bin/epro-ws ]; then
    echo "O proxy já está instalado. Ignorando a instalação."
else
# Função para instalar o proxy
    install_proxy() {
        echo "Instalando o proxy..."
        {
            rm -f /usr/bin/epro-ws
            curl -s -L -o /usr/bin/proxy https://raw.githubusercontent.com/PhoenixxZ2023/ws-epro1/main/epro-ws
            chmod +x /usr/bin/epro-ws
        } > /dev/null 2>&1
        echo "WS-EPRO instalado com sucesso."
    }
    
# Instalar o proxy
    install_epro-ws
fi


uninstall_proxy() {
    echo -e "\nDesinstalando o epro-ws..."
    
# Encontra e remove todos os arquivos de serviço do proxy
    service_files=$(find /etc/systemd/system -name 'epro-ws-*.service')
    for service_file in $service_files; do
        service_name=$(basename "$service_file")
        service_name=${service_name%.service}
        
 # Verifica se o serviço está ativo antes de tentar parar e desabilitar
        if  systemctl is-active "$service_name" &> /dev/null; then
            systemctl stop "$service_name"
            systemctl disable "$service_name"
        fi
        
        rm -f "$service_file"
        echo "Serviço $service_name parado e arquivo de serviço removido: $service_file"
    done
    
 # Remove o arquivo binário do proxy
    rm -f /usr/bin/epro-ws
    
    echo "Proxy desinstalado com sucesso."
}

# Configurar e iniciar o serviço
    configure_and_start_service() {
    read -p "QUE PORTA DESEJA ATIVAR? : " PORT
    read -p "Você quer usar HTTP(H) ou HTTPS(S)?: " HTTP_OR_HTTPS
    if [[ $HTTP_OR_HTTPS == "S" || $HTTP_OR_HTTPS == "s" ]]; then
    read -p "Digite o caminho do certificado (--cert): " CERT_PATH
    fi
    read -p "DIGITE STATUS DO WS-EPRO: " RESPONSE
    read -p "Você quer usar apenas SSH (Y/N)?: " SSH_ONLY
    
# Defina as opções de comando
    OPTIONS="--port $PORT"
    
    if [[ $HTTP_OR_HTTPS == "S" || $HTTP_OR_HTTPS == "s" ]]; then
        OPTIONS="$OPTIONS --https --cert $CERT_PATH"
    else
        OPTIONS="$OPTIONS --http"
    fi
    
    if [[ $SSH_ONLY == "Y" || $SSH_ONLY == "y" ]]; then
        OPTIONS="$OPTIONS --ssh-only"
    fi
    
 # Crie o arquivo de serviço
    SERVICE_FILE="/etc/systemd/system/epro-ws-$PORT.service"
    echo "[Unit]" > "$SERVICE_FILE"
    echo "Description=WS-EPRO ATIVO NA PORTA $PORT" >> "$SERVICE_FILE"
    echo "After=network.target" >> "$SERVICE_FILE"
    echo "" >> "$SERVICE_FILE"
    echo "[Service]" >> "$SERVICE_FILE"
    echo "Type=simple" >> "$SERVICE_FILE"
    echo "User=root" >> "$SERVICE_FILE"
    echo "WorkingDirectory=/root" >> "$SERVICE_FILE"
    echo "ExecStart=/usr/bin/epro-ws $OPTIONS --buffer-size 2048 --workers 5000 --response $RESPONSE" >> "$SERVICE_FILE" 
    
# Parâmetro --response no final
    echo "Restart=always" >> "$SERVICE_FILE"
    echo "" >> "$SERVICE_FILE"
    echo "[Install]" >> "$SERVICE_FILE"
    echo "WantedBy=multi-user.target" >> "$SERVICE_FILE"
    
# Recarregue o systemd
    systemctl daemon-reload
    
# Inicie o serviço e configure o início automático
    systemctl start epro-ws-$PORT
    systemctl enable epro-ws-$PORT
    
    echo "O serviço do proxy na porta $PORT foi configurado e iniciado automaticamente."
}

stop_and_remove_service() {
    read -p "QUE PORTA DESEJA PARAR?: " service_number
    
 # Parar o serviço
    systemctl stop epro-ws-$service_number
    
# Desabilitar o serviço
    systemctl disable epro-ws-$service_number
    
# Encontrar e remover o arquivo do serviço
    service_file=$(find /etc/systemd/system -name "epro-ws-$service_number.service")
    if [ -f "$service_file" ]; then
        rm "$service_file"
        echo "PORTA REMOVIDA COM SUCESSO: $service_file"
    else
        echo "Arquivo de serviço não encontrado para o serviço epro-ws-$service_number."
    fi
    
    echo "PORTA PROXY-$service_number parado e removido."
}

# Menu de gerenciamento
while true; do
    clear
    echo -e "\E[41;1;37m       🚀   TURBONET WS-EPRO  🚀           \E[0m"
              echo ""
    echo -e "\033[01;31m║\033[0m\033[1;31m[\033[1;36m1\033[1;31m] \033[1;37m• \033[1;33mINSTALAR TURBONET WS-EPRO \033[0m"
    echo -e "\033[01;31m║\033[0m\033[1;31m[\033[1;36m2\033[1;31m] \033[1;37m• \033[1;33mPARAR E REMOVER PORTA \033[0m"
    echo -e "\033[01;31m║\033[0m\033[1;31m[\033[1;36m3\033[1;31m] \033[1;37m• \033[1;33mREINICIAR WS-EPRO \033[0m"
    echo -e "\033[01;31m║\033[0m\033[1;31m[\033[1;36m4\033[1;31m] \033[1;37m• \033[1;33mVER STATUS DO WS-EPRO \033[0m"
    echo -e "\033[01;31m║\033[0m\033[1;31m[\033[1;36m5\033[1;31m] \033[1;37m• \033[1;33mREINSTALAR WS-EPRO \033[0m"
    echo -e "\033[01;31m║\033[0m\033[1;31m[\033[1;36m6\033[1;31m] \033[1;37m• \033[1;33mSAIR \033[0m"
    echo ""
    echo -ne "\033[1;31m➤ \033[1;32mESCOLHA OPÇÃO DESEJADA\033[1;33m\033[1;31m\033[1;37m"
    read -p ": " choice
    case $choice in
    1 | 01)
        configure_and_start_service
        ;;
    2 | 02)
        stop_and_remove_service
        ;;
    3 | 03)
        echo "Serviços em execução:"
        systemctl list-units --type=service --state=running | grep epro-ws
        read -p "QUAL PORTA DESEJA REINICIAR?: " service_number
        systemctl restart epro-ws-$service_number
        echo "Serviço epro-ws-$service_number reiniciado."
        ;;
    4 | 04)
        systemctl list-units --type=service --state=running | grep epro-ws
        ;;
    5 | 05)
        echo "Desinstalando o epro-ws antes de reinstalar..."
        uninstall_epro-ws
        install_epro-ws
        ;;
    6 | 06)
        echo "Saindo."
        break
        ;;
        *)
        echo "Opção inválida. Escolha uma opção válida."
        ;;
    esac
    
    read -p "Pressione Enter para continuar..."
done
