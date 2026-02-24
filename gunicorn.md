# Gunicorn

“Green Unicorn”  
Python Web Server Gateway Interface HTTP server  
bridges web servers and Python web applications  
can spawn multiple worker processes to handle incoming requests simultaneously  
running gunicorn with the --workers=4 option, we are specifying that we want four workers ready to tackle clients’ requests  
--threads=2 indicates that each worker process can spawn two threads  

```md
gunicorn --workers=4 --threads=2 -b 0.0.0.0:8080 app:app
[2024-04-16 23:35:59 +0300] [507149] [INFO] Starting gunicorn 21.2.0
[2024-04-16 23:35:59 +0300] [507149] [INFO] Listening at: http://0.0.0.0:8080 (507149)
[2024-04-16 23:35:59 +0300] [507149] [INFO] Using worker: gthread
[2024-04-16 23:35:59 +0300] [507150] [INFO] Booting worker with pid: 507150
[2024-04-16 23:35:59 +0300] [507151] [INFO] Booting worker with pid: 507151
[2024-04-16 23:35:59 +0300] [507152] [INFO] Booting worker with pid: 507152
[2024-04-16 23:35:59 +0300] [507153] [INFO] Booting worker with pid: 50715
```