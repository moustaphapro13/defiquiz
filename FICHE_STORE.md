# Défi Quiz : pack de publication

## 1. Fiche Play Store (FR)

**Nom de l'appli (30 car. max)** : Défi Quiz : duels de culture G

**Description courte (80 car. max)** :
Des milliers de questions, des duels en direct et un défi chaque jour. Sans pub.

**Description complète** :

Prêt à prouver que tu sais tout ? Défi Quiz, c'est le quiz rapide et fun auquel on revient chaque jour.

⚡ RÉPONDS VITE, MARQUE PLUS
10 questions, 10 secondes chacune : plus tu réponds vite, plus tu gagnes de points. La dernière question compte double.

🎯 PLUS DE 50 THÈMES ET SOUS-THÈMES
Culture G, foot, rap, RnB, Pokémon, séries, manga, histoire, cinéma, jeux vidéo, astrologie, espace, mythologie… Chaque thème a ses sous-thèmes, et trois niveaux de difficulté. Les questions difficiles sont vraiment difficiles.

🔥 DÉFIE TES AMIS
Duel en direct contre un adversaire au hasard ou un ami, défis de groupe, tournois du week-end et classements.

📅 UN DÉFI PAR JOUR
Le même défi pour tout le monde, chaque jour. Compare ton score et garde ta série.

🏆 PASS DE SAISON
Monte de niveau, gagne des pièces, débloque des cadres, des titres et des objets à voir en 3D.

💬 COMMUNAUTÉ
Salons par thème, groupes privés, messages. Les messages des salons s'effacent après 24 h.

✈️ MÊME HORS LIGNE
Le mode solo fonctionne sans Internet : idéal dans le métro ou en avion.

🚫 SANS PUB
Aucune publicité. Le jeu est gratuit ; un Pass Premium facultatif soutient le projet.

**Catégorie** : Jeux → Quiz
**Tags** : quiz, culture générale, trivia, questions, duel
**Classification du contenu (IARC)** : questionnaire à remplir. Réponses : pas de violence, pas de contenu sexuel, chat entre utilisateurs = OUI (modéré, signalement possible), achats numériques = OUI. Résultat attendu : PEGI 12 / Tout public avec interactions.
**Public cible** : 13 ans et plus (pas « conçu pour les enfants »).

## 2. Sécurité des données (formulaire Play Console)

| Question | Réponse |
|---|---|
| Collecte des données ? | Oui |
| Chiffrées en transit ? | Oui (HTTPS) |
| Suppression possible ? | Oui : dans l'appli (Profil → Compte) + page web legal.html#suppression |
| Données collectées | Adresse e-mail (facultative, gestion du compte) ; Nom d'utilisateur/pseudo ; Photos (facultatif, photo de profil) ; Messages dans l'appli ; Activité dans l'appli (scores, parties) ; Historique d'achat (Pass Premium) ; Identifiants de l'appareil : NON |
| Partage avec des tiers | Non (prestataires techniques seulement) |
| Publicité / suivi | Non |

**URL politique de confidentialité** : https://moustaphapro13.github.io/defiquiz/legal.html#confidentialite
**URL suppression de compte** : https://moustaphapro13.github.io/defiquiz/legal.html#suppression

## 3. Captures d'écran

Dossier `screens/` (1080 × 2340) : bienvenue, accueil, thème, question, résultat.

## 4. Publier sur le Play Store avec PWABuilder

1. Va sur pwabuilder.com, entre `https://moustaphapro13.github.io/defiquiz/`, clique sur « Start ».
2. « Package for stores » → Android → « Generate package ». Garde l'identifiant proposé (ex. `io.github.moustaphapro13.defiquiz`). Télécharge le zip.
3. Dans le zip : le fichier `.aab` (à envoyer sur la Play Console), `signing.keystore` + `signing-key-info.txt` (à **garder précieusement**, indispensable pour les mises à jour) et `assetlinks.json`.
4. Mets `assetlinks.json` en ligne pour que l'appli s'ouvre sans barre d'adresse. Sur GitHub Pages d'un projet, ce fichier doit être à la racine du domaine (`moustaphapro13.github.io/.well-known/assetlinks.json`) : crée un dépôt `moustaphapro13.github.io` contenant `.well-known/assetlinks.json`, plus un fichier vide `.nojekyll`.
5. Play Console (compte développeur 25 $, vérification d'identité) → Créer une appli → remplis la fiche avec le texte ci-dessus → Test fermé (obligatoire pour un nouveau compte perso : 12 testeurs pendant 14 jours) → Production.

**Paiements** : Google exige sa propre facturation pour les contenus numériques dans les applis Android. L'appli détecte donc automatiquement quand elle est lancée depuis le Play Store, et l'achat du Pass Premium y est désactivé. Sur le site web, l'achat reste possible via Stripe. Dans PWABuilder, mets l'URL de démarrage à `/defiquiz/?src=twa`.

## 5. iPhone

Pas besoin de l'App Store : sur Safari, « Partager → Sur l'écran d'accueil » installe Défi Quiz comme une appli (icône, plein écran, notifications sous iOS 16.4+).
