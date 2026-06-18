#!/bin/bash
set -e

echo ">> Aplicando a Fase 1 de UI/UX (Tema Dark, Ícones Papirus, Fontes Inter)..."

add-apt-repository ppa:papirus/papirus -y
apt update
apt install -y papirus-icon-theme fonts-inter fonts-roboto

# Estruturar Esqueleto de novos usuários (/etc/skel)
mkdir -p /etc/skel/Desktop
mkdir -p "/etc/skel/Área de Trabalho"

# Copiar atalhos para os Desktops padrões
cp /usr/share/applications/holyrics.desktop /etc/skel/Desktop/ 2>/dev/null || true
cp /usr/share/applications/holyrics.desktop "/etc/skel/Área de Trabalho/" 2>/dev/null || true
cp /usr/share/applications/mixing-station.desktop /etc/skel/Desktop/ 2>/dev/null || true
cp /usr/share/applications/mixing-station.desktop "/etc/skel/Área de Trabalho/" 2>/dev/null || true

cp /usr/share/applications/ubuntu-bibletime.desktop /etc/skel/Desktop/ 2>/dev/null || cp /usr/share/applications/bibletime.desktop /etc/skel/Desktop/ 2>/dev/null || true
cp /usr/share/applications/ubuntu-bibletime.desktop "/etc/skel/Área de Trabalho/" 2>/dev/null || cp /usr/share/applications/bibletime.desktop "/etc/skel/Área de Trabalho/" 2>/dev/null || true

chmod +x /etc/skel/Desktop/*.desktop 2>/dev/null || true
chmod +x "/etc/skel/Área de Trabalho/"*.desktop 2>/dev/null || true

# Configurar Wallpaper Real do BibleOS
mkdir -p /usr/share/backgrounds/bibleos
if [ -f "/biblia-padrao.jpg" ]; then
    mv /biblia-padrao.jpg /usr/share/backgrounds/bibleos/
fi

# Injetar os XMLs de configuração de ambiente padrão do XFCE
mkdir -p /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml

# Configuração de Tela e Monitores (Estendido para Projeção)
cat << 'EOF' > /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="image-path" type="string" value="/usr/share/backgrounds/bibleos/biblia-padrao.jpg"/>
        <property name="image-style" type="int" value="5"/>
      </property>
      <property name="monitor1" type="empty">
        <property name="image-path" type="string" value="/usr/share/backgrounds/bibleos/biblia-padrao.jpg"/>
        <property name="image-style" type="int" value="5"/>
      </property>
      <property name="monitorDEFAULT" type="empty">
        <property name="image-path" type="string" value="/usr/share/backgrounds/bibleos/biblia-padrao.jpg"/>
        <property name="image-style" type="int" value="5"/>
      </property>
    </property>
  </property>
</channel>
EOF

# Configuração de Tema Escuro e Tipografia Inter
cat << 'EOF' > /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Mint-Y-Dark"/>
    <property name="IconThemeName" type="string" value="Papirus-Dark"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="FontName" type="string" value="Inter 10"/>
    <property name="MonospaceFontName" type="string" value="Monospace 10"/>
  </property>
  <property name="Xft" type="empty">
    <property name="Antialias" type="int" value="1"/>
    <property name="Hinting" type="int" value="1"/>
    <property name="HintStyle" type="string" value="hintslight"/>
    <property name="RGBA" type="string" value="rgb"/>
  </property>
</channel>
EOF

# Limpeza absoluta de cache apt para otimização da ISO
apt autoremove -y && apt clean && rm -rf /tmp/*