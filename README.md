# Your Car Your Way - PoC Chat en ligne

## 1. Objectif

Ce repository contient une **preuve de concept (PoC)** de la fonctionnalité de chat en ligne de l'application **Your Car Your Way**.

L'objectif est volontairement limité : **valider la faisabilité d'un échange bidirectionnel en temps réel entre un client et le service client**.

Le PoC utilise :

- **Angular** pour l'interface web ;
- **Java 21 + Spring Boot 4.1.1** pour le backend ;
- **Spring WebSocket** pour la communication en temps réel.

Le PoC ne cherche pas à reproduire l'application complète. Il n'implémente donc pas la réservation, le paiement, la persistance MySQL, l'authentification JWT ou la visioconférence.

Ces éléments font partie de l'architecture globale mais ne sont pas nécessaires pour valider le fonctionnement du chat.

## 2. Fonctionnalités

Le PoC permet :

- de se connecter à une conversation avec un `conversationId` ;
- de choisir un nom et un rôle (client ou service client) ;
- d'envoyer et de recevoir des messages en temps réel ;
- d'isoler les échanges entre différentes conversations ;
- d'ajouter l'heure du message côté serveur ;
- de valider simplement le contenu des messages ;
- d'afficher l'état de la connexion WebSocket.

## 3. Architecture

```text
Navigateur
    |
    | Angular
    |
    | WebSocket
    v
Spring Boot
    |
    | ChatWebSocketHandler
    v
Sessions regroupées par conversationId
```

Le frontend communique directement avec le backend via WebSocket.

Exemple de connexion :

```text
ws://localhost:8080/ws?conversationId=conversation-001
```

Le backend conserve uniquement les sessions WebSocket actives en mémoire.

Les messages ne sont pas persistés dans le cadre du PoC.

## 4. Prérequis

- Java 21
- Node.js
- npm

Le projet backend contient Maven Wrapper. Il n'est donc pas nécessaire d'installer Maven séparément.

## 5. Installation

Cloner le repository :

```bash
git clone <URL_DU_REPOSITORY>
cd oc_projet13_poc_chat
```

Installer les dépendances Angular :

```bash
cd frontend
npm install
```

## 6. Lancer le backend

Depuis la racine du repository :

```bash
cd backend
./mvnw spring-boot:run
```

Le backend démarre sur :

```text
http://localhost:8080
```

L'endpoint WebSocket est :

```text
ws://localhost:8080/ws?conversationId={conversationId}
```

## 7. Lancer le frontend

Dans un second terminal :

```bash
cd frontend
npm start
```

Ouvrir ensuite :

```text
http://localhost:4200
```

## 8. Démonstration

Pour tester le PoC :

1. Ouvrir `http://localhost:4200` dans deux onglets.
2. Utiliser le même `conversationId` dans les deux onglets, par exemple `conversation-001`.
3. Se connecter comme client dans le premier onglet.
4. Se connecter comme service client dans le second onglet.
5. Envoyer un message depuis le premier onglet.
6. Vérifier que le message apparaît dans les deux onglets.
7. Répondre depuis le second onglet.

Pour vérifier l'isolation des conversations, ouvrir un troisième onglet avec :

```text
conversation-002
```

Cet onglet ne doit pas recevoir les messages de `conversation-001`.

## 9. Choix techniques

### WebSocket

WebSocket est utilisé car le chat nécessite une communication bidirectionnelle en temps réel.

La connexion persistante permet au serveur et au client d'échanger des messages sans effectuer régulièrement des requêtes HTTP.

### Isolation des conversations

Les connexions WebSocket sont regroupées par `conversationId`.

Un message est envoyé uniquement aux sessions appartenant à la même conversation.

### Validation

Une validation simple est réalisée côté backend afin de refuser les messages vides ou trop longs.

Une validation côté frontend améliore également l'expérience utilisateur.

### Pas de persistance dans le PoC

Les messages sont conservés uniquement pendant la session.

La persistance n'est pas nécessaire pour démontrer la faisabilité technique du chat en temps réel.

### Pas d'authentification

L'architecture complète prévoit l'utilisation de Spring Security et JWT.

L'authentification n'est pas implémentée dans ce PoC afin de limiter le développement à la fonctionnalité demandée.

Dans une application de production, l'identité et le rôle de l'utilisateur seraient déterminés à partir de l'utilisateur authentifié.

## 10. Limites du PoC

Ce PoC n'est pas destiné à être utilisé directement en production.

Il ne contient pas :

- l'authentification et l'autorisation ;
- la persistance des messages ;
- l'historique du chat ;
- l'affectation d'un conseiller ;
- le chiffrement TLS (`wss://`) ;
- la gestion de plusieurs instances du backend.

Ces fonctionnalités ne sont pas nécessaires pour démontrer la faisabilité de la communication en temps réel.

## 11. Structure de la base de données

Le repository contient également le script SQL décrivant la structure de données de l'application complète :

```text
database/schema.sql
```

Ce script est prévu pour **MySQL 8.0+** et contient les tables principales, les clés étrangères, les contraintes et les index nécessaires.

Pour l'exécuter :

```bash
mysql -u root -p < database/schema.sql
```

La base MySQL n'est **pas nécessaire pour exécuter le PoC du chat**.

Le script SQL est fourni séparément afin de représenter la structure de données prévue pour l'application complète.