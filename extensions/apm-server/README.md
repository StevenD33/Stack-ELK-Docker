# Extension APM Serveur

Ajoute un conteneur pour elasticsearch APM serveur. pour forward les erreurs sur Elasticsearch et activer leurs visualisation dans kibana.

## utilisation


Pour ajouter l'apm serveur, il faut lancer le docker compose dpuis le root du répo avec la commande en plus qui fait référence dans le `apm-server-compose.yml` 

```console
$ docker-compose -f docker-compose.yml -f extensions/apm-server/apm-server-compose.yml up
```

## Connecter un agent vers Le serveur APM


La config basic pour envoyer des traces vers le serveur APM est de spécifier le `SERVICE_NAME` et `SERVICE_URL`. en dessous voilà un exemple de config en utilisant un script python et flask

```python
import elasticapm
from elasticapm.contrib.flask import ElasticAPM

from flask import Flask

app = Flask(__name__)
app.config['ELASTIC_APM'] = {
    # Changé le nom du service. 
    'SERVICE_NAME': 'PYTHON_FLASK_TEST_APP',

    # Changer l'url du serveur APM (http://localhost:8200)
    'SERVER_URL': 'http://apm-server:8200',

    'DEBUG': True,
}
```

Plus de settings sont dispo dans la catégorie **Configuration**
https://www.elastic.co/guide/en/apm/agent/index.html

## Vérifier la connetivité et importé les dashboard APM par défaut 

Depuis le Dashboard Kibana:

1. `Add APM` en dessous de la section _Add Data to Kibana_ section
2. Ignorer toutes les instruction d'installtion et cliquer sur `Check APM Server status`.
3. Cluquer sur `Check agent status`
4. Cliquer sur  `Load Kibana objects` pour avoir les dashboard par défaut
5. et ensuite cliquer sur `APM dashboard` en bas à droite .

## See also

[Exec APM serveur sur DOCKER](https://www.elastic.co/guide/en/apm/server/current/running-on-docker.html)
