# Stack-ELK-Docker

## installation 


vérifier que l'on a bien docker d'installé et lancé sur sa machine.

```bash
git clone https://github.com/StevenDias33/Stack-ELK-Docker
docker-compose build
docker-compose up

```

attendre un peu et vous allez avoir la stack elk qui va se monter sur vos ports 9600 5601 5000 9200 9300 donc en gros les ports par défaut utiliser par les différents services. 

Pour kibana il faut aller sur http://127.0.0.1:5601

Les credentials sont 

```
username: elastic
pass: changeme
```

## Utilisation 

Ensuite pour l'utilisation c'est comme une stack elk basique il faut configurer logstash et des différentes sondes pour ensuite synchro tout avec elastic et avec kibana il faut config le dashboard que l'on souhaite avoir 
