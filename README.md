## PROJET GCP / DÉPLOIEMENT D'UN SITE ECOMMERCE

---

#### 1. Présentation

Le but du projet est de mettre en place une architecture applicative prenant en compte.

- Une phase de provisionnement et de configuration.
- Une phase d’automatisation et de déploiement allant du versionning jusqu’au déploiement
  des micro-services dans des conteneurs Docker et managé par un orchestrateur (Kubernetes).

La solution applicative est un site e-commerce structuré en microservice avec un accès à une base de données.

L’ensemble de l’architecture et des ressources seront mises en place et déployé dans le Cloud Provider GCP.

Chacun des services de l’application a été conçu avec des technologies et des langages variés (GO, JS, Python, C#, etc…).

Les technologies dont vous aurez besoin pour mener à bien ce projet :

- Terraform
- Ansible
- Kubernetes
- Git
- Etc…

Pour vous aider à réaliser le projet des schémas fournis, ci-après.

| ![image1.jpg](https://raw.githubusercontent.com/gcp-project-formation/terraform/main/images/image1.png) |
| :-----------------------------------------------------------------------------------------------------: |
|                                               _Schéma 1_                                                |

| ![image1.jpg](https://raw.githubusercontent.com/gcp-project-formation/terraform/main/images/image2.png) |
| :-----------------------------------------------------------------------------------------------------: |
|                                               _Schéma 2_                                                |

#### 2. Terraform

Créez un compte de service dédié aux déploiements de votre infrastructure.
Avec Terraform vous allez provisionner les ressources suivantes :

- 1 VPC :

  - Région 1 : 2 zones avec 1 sous-réseau.
  - Région 2 : 1 zone avec 1 sous-résau.

- Dans la région 1, vous y déploierez votre cluster Kubernetes.
- Dans la région2, vous y déploierez votre serveur de Redis (VM + serveur Redis).
- Autres ressources que vous jugerez nécessaires pour votre infrastructure.

###### Etape 1

Pour garantir la haute disponibilité de vos données, il faudra définir dans votre script, au minimum, les éléments suivants :

- Groupe d’instance.
- Template d’instance.
- Un seuil de scale : 65 % CPU.
- Un nombre maximum d’instance de 3.
- Un loadbalancer.
- Firewall nécéssaire.
- Etc.

Dans votre script, Il faudra aussi mettre en place une surveillance de votre instance avec le service de monitoring vous permettant :

- De créer un dashboard mettant en avant les éléments de surveillance que vous jugerez nécessaires (que vous justifierez),
- Ainsi que des alertes rattachées (par mail) aux éléments de surveillance (comme par exemple CPU, Stockage, trafics entrant).

    ###### Ansible :

    Le lancement d’Ansible sera exécuté à partir de Terraform.

    Avec Ansible, vous définirez les étapes nécessaires à l’installation de Redis dans votre instance.

###### Etape 2 :

Toujours avec Terraform, il faudra créer l’infrastructure nécessaire au déploiement de votre Cluster.
Kubernetes dans la région 1 avec la configuration suivante :

- 3 nœuds.
- Nombre maximum de pods par nodes : 30.
- 100 GB par node (en fonction de vos ressources disponibles)
- Nombre maximum de node : 3.
- Nombre minimum de node : 1.
- Service Loadbalancing activé.
- Monitoring avec Prometheus.

N’hésitez pas à définir toutes les variables que vous estimeriez nécessaire ainsi que les outputs qui vont permettront de visualiser les informations des ressources crées.

#### 3. CI/CD

Une fois l’infrastructure mise en place, vous allez pouvoir mettre en place votre pipeline CI/CD :

- Le code source de chaque service sera présent dans un repository dans le service Cloud Source Repository.
- Le service Cloud Build va vous permettre d’effectuer un build du service en vous basant sur sur son Dockefile. Il faudra ensuite mettre à jour le deployment concerné.
- Chaque image image qui fera l’image d’un build devra être répertorié avec un numéro de version unique.
- Chaque image qui sera sur le Container Registry aura fait l’objet d’une vérification des vulnérabilités et sera modifié si nécessaire.
- Les deployments, les services et autres ressources Kubernetes devront être stockés dans un bucket Cloud Storage.
- Le deployement des ressources kubernertes se fera avec Cloud Build.
- Chaque modification du code source commité et pushé sur le master, fera l’objet d’une mise à jour automatisée dans votre cluster.

#### 4. Kubernetes

Pour votre Cluster, vous aurez besoin des informations suivantes :

- Chaque microservice fera l’objet d’un deployment et d’un service qui l’exposera si nécessaire avec le bon niveau d’exposition (ClusterIP, NodePort, etc.).
- En fonction du nombre de node de vous disposez, il faudra répartir les pods de façon uniforme dans chacun de vos nodes (scheduling) sur des critères comme nodeSelector, affinityNode, affinityPod, etc.
- Il faudra faire en sort que votre node master ne puisse accueillir de pod.
- Les éléments de configuration, si nécessaire, seront stockés dans une ConfigMap.
- Les éléments d’authentification qui nécessiteront de ne pas être en clair seront gerés pas un ou plusieurs « Secret ».
- Vous allez créer au moins 2 namespaces pour catégoriser vos ressources et vous assurez une meilleure gestion de vos ressources.
- Chaque Deployment sera configuré pour garantir la haute disponibilité de ses ressources avec au minimum 1 pod et maximum 3 pods avec comme seuil une consommation CPU moyenne de 70% (N’hésitez pas à tester son fonctionnement : stress test)
- Il faudra aussi mettre en place la communication entre votre Cluster Kubernetes et le serveur de donnée Redis (donnée en cache).
- Il faudra aussi mettre en place un outil de monitoring comme Prometheus associé avec Grafana pour la partie UI pour votre Cluster Kubernetes. Pour vous aider, n’hésitez pas à lancer et analyser le Docker-Compose.yaml. Il vous fournira des informations importantes.
