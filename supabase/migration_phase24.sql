-- Défi Quiz · phase 24 : sous-thèmes de mythologie, doublons, tirage équilibré, durée des duels
begin;
insert into public.theme_tree(child, parent) values ('egyptienne','mytho'),('romaine','mytho'),('celtique','mytho'),('asiatique','mytho'),('precolombienne','mytho') on conflict do nothing;
update public.questions set theme = 'grecque' where theme = 'mytho' and question in ('Quelle cité a été prise grâce à un grand cheval de bois ?', 'Qui a ouvert la jarre qui libéra tous les maux sur le monde ?', 'Quelle déesse grecque est sortie tout armée de la tête de Zeus ?', 'Qui a donné à Thésée le fil pour sortir du labyrinthe ?', 'Quel jeune homme est tombé amoureux de son propre reflet ?', 'Quel musicien est descendu aux Enfers pour ramener Eurydice ?', 'Quel dieu grec est celui du vin et de la fête ?', 'Quelle créature au regard pétrifiant a été décapitée par Persée ?', 'Combien de travaux Héraclès a-t-il accomplis ?', 'Qui s''est trop approché du soleil avec des ailes de cire ?', 'Quel dieu grec règne sur les mers ?', 'Quel monstre voyait ses têtes repousser quand on les coupait ?', 'Quel héros grec n''était vulnérable qu''au talon ?', 'Quel roi d''Ithaque met dix ans à rentrer chez lui dans l''« Odyssée » ?', 'Quel héros a tué le Minotaure dans le labyrinthe ?', 'Quel titan a volé le feu des dieux pour le donner aux hommes ?', 'Qui est le roi des dieux grecs ?', 'Comment s''appelle le chien à trois têtes qui garde les Enfers ?', 'Quel héros grec a accompli douze travaux ?');
update public.questions set theme = 'nordique' where theme = 'mytho' and question in ('Quel dieu nordique farceur est le père du loup Fenrir ?', 'Comment s''appelle le serpent géant qui entoure le monde chez les Vikings ?', 'Quel dieu nordique manie le marteau Mjöllnir ?', 'Quel dieu nordique borgne est le père de tous les dieux ?', 'Où vont les guerriers morts au combat dans la mythologie nordique ?');
update public.questions set theme = 'egyptienne' where theme = 'mytho' and question in ('Quel est le grand dieu-soleil de l''Égypte antique ?', 'Quel dieu égyptien à tête de chacal veille sur la momification ?', 'Quel dieu égyptien à tête de faucon est le fils d''Isis et d''Osiris ?', 'Quel dieu égyptien a tué son frère Osiris ?', 'Quelle déesse égyptienne à tête de chat protège le foyer ?', 'La plume contre laquelle on pèse le cœur des morts appartient à quelle déesse ?', 'Quel dieu égyptien à tête d''ibis est celui de l''écriture et du savoir ?', 'Dans quelle salle les âmes égyptiennes voient-elles leur cœur pesé contre une plume ?', 'Dans quelle civilisation adorait-on Râ, Osiris et Isis ?', 'Quelle déesse égyptienne est l''épouse d''Osiris et la mère d''Horus ?', 'Quel dieu égyptien est représenté avec une tête de chacal ?', 'Quel dieu égyptien à tête de crocodile vit dans le Nil ?');
update public.questions set theme = 'romaine' where theme = 'mytho' and question in ('Quel est le nom romain de Zeus ?', 'Quel est le dieu romain de la guerre ?', 'Quelle déesse romaine de l''amour correspond à Aphrodite ?', 'Quel dieu romain à deux visages a donné son nom à janvier ?', 'Quel dieu romain correspond à Héphaïstos ?', 'Quel dieu romain correspond à Poséidon ?', 'Quelle déesse romaine de la chasse correspond à Artémis ?', 'Quelle déesse romaine de la sagesse correspond à Athéna ?', 'Quel est le nom romain d''Hermès, messager des dieux ?');
update public.questions set theme = 'asiatique' where theme = 'mytho' and question in ('Quel dieu hindou forme la trinité avec Brahmā et Shiva ?', 'Quel dieu hindou à tête d''éléphant lève les obstacles ?', 'Quelle déesse du soleil est la plus importante du shintoïsme japonais ?', 'Quelle déesse hindoue, épouse de Vishnou, est celle de la fortune ?', 'Quelle créature japonaise est un renard magique à plusieurs queues ?');
update public.questions set theme = 'precolombienne' where theme = 'mytho' and question in ('Quel serpent à plumes est une grande divinité aztèque ?', 'Quel dieu aztèque de la guerre et du soleil exigeait des sacrifices ?', 'Quel dieu inca était le dieu du soleil ?', 'Quel dieu aztèque était associé à la pluie ?');
update public.questions set theme = 'celtique' where theme = 'mytho' and question in ('Quel magicien conseille le roi Arthur ?', 'Quelle épée Arthur retire-t-il de la pierre ?', 'Dans la mythologie celte irlandaise, quel héros est surnommé « le chien de Culann » ?', 'Quel héros irlandais a goûté le saumon de la connaissance ?');
update public.questions q set active = false from (values ('Quel rappeur d''Aulnay-sous-Bois a sorti « Agartha » ?','Vald'), ('Quel célèbre personnage de Nintendo est un plombier moustachu en salopette ?','Mario'), ('Combien de joueurs par équipe sont sur le terrain au basket ?','5'), ('Quel DJ français a produit « Titanium » avec Sia ?','David Guetta'), ('Quel physicien a découvert la radioactivité en 1896 ?','Henri Becquerel'), ('Quel film de Dany Boon se déroule à Bergues, dans le Nord ?','Bienvenue chez les Ch''tis'), ('Combien de litres de sang un adulte a-t-il environ ?','5 litres'), ('Quel titan a volé le feu aux dieux pour le donner aux hommes ?','Prométhée'), ('Quel navire Franky construit-il pour l''équipage ?','Le Thousand Sunny'), ('Comment s''appellent les récompenses du cinéma français ?','Les César'), ('Quel est l''élément le plus léger de l''univers ?','L''hydrogène'), ('Quel film de 2011 avec Omar Sy et François Cluzet a attiré plus de 19 millions de spectateurs ?','Intouchables'), ('Quel prix récompense le meilleur film au Festival de Cannes ?','La Palme d''or'), ('Comment appelle-t-on le score de 40 partout ?','Égalité'), ('Quelle planète tourne « couchée » sur le côté ?','Uranus'), ('Qui est le dieu principal, « père de tous », de la mythologie nordique ?','Odin'), ('Quel chef gaulois a capitulé devant César à Alésia ?','Vercingétorix'), ('Qui a ouvert la jarre qui a libéré tous les maux sur le monde ?','Pandore'), ('Quel joueur suisse a remporté huit fois Wimbledon ?','Roger Federer'), ('Comment s''appelle la princesse que Mario doit souvent sauver ?','Peach'), ('Quel serpent géant entoure le monde des humains ?','Jörmungand'), ('Qui est l''auteur de One Piece ?','Eiichiro Oda'), ('Quelle sonde, lancée en 1977, est l''objet humain le plus éloigné de la Terre ?','Voyager 1'), ('Combien de boules de cristal faut-il réunir pour invoquer le dragon ?','7'), ('En quelle année Guillaume le Conquérant a-t-il gagné la bataille d''Hastings ?','1066'), ('Quel est l''ennemi juré de Mario ?','Bowser'), ('Quelle mission a posé les premiers hommes sur la Lune ?','Apollo 11'), ('En quelle année l''Empire romain d''Occident a-t-il disparu ?','476'), ('Comment s''appelle le héros de la saga « The Legend of Zelda » ?','Link'), ('Qui aide Thésée à sortir du labyrinthe grâce à un fil ?','Ariane'), ('Qui a créé Dragon Ball ?','Akira Toriyama'), ('Quel rover de la NASA explore Mars depuis 2021 ?','Perseverance'), ('Quel est l''organe interne le plus lourd du corps ?','Le foie'), ('Combien de dents de lait a un enfant ?','20'), ('Quel roi des Francs a été baptisé à Reims vers 496 ?','Clovis'), ('Quelle dynastie de rois fonde Hugues Capet en 987 ?','Les Capétiens'), ('Quel pharaon a fait bâtir la plus grande pyramide de Gizeh ?','Khéops'), ('Quelle ville accueillera les Jeux olympiques d''été de 2028 ?','Los Angeles'), ('Quelle déesse est née tout armée de la tête de Zeus ?','Athéna'), ('Quel chien à trois têtes garde l''entrée des Enfers ?','Cerbère'), ('Comment s''appelle le renne médecin de l''équipage ?','Tony Tony Chopper'), ('Quel type a été ajouté dans Pokémon X et Y ?','Fée'), ('Quel joueur détient le record mondial de buts en sélection nationale ?','Cristiano Ronaldo'), ('Quel langage de programmation porte le nom d''une troupe d''humoristes britanniques ?','Python'), ('Quelle marque installée à Molsheim, en Alsace, produit la Chiron ?','Bugatti'), ('Combien de cœurs a une pieuvre ?','3'), ('Quel jeu mobile de 2016 fait chasser les Pokémon dans la vraie vie ?','Pokémon GO'), ('Quel Grand Prix de F1 se court dans les rues de la Principauté depuis 1929 ?','Le Grand Prix de Monaco'), ('En quelle année est sorti le premier iPhone ?','2007'), ('Combien de badges faut-il pour accéder à la Ligue Pokémon de Kanto ?','8'), ('Quel jeu de FromSoftware (2022) se déroule dans l''Entre-terre ?','Elden Ring'), ('Quel pilote britannique a remporté sept titres de champion du monde de F1 ?','Lewis Hamilton'), ('Comment s''appelle le petit de la vache ?','Le veau'), ('Combien de temps dure la gestation d''une éléphante ?','Environ 22 mois'), ('Quel service français a précédé Internet dans les années 1980 ?','Le Minitel'), ('Combien de pattes a un crabe, pinces comprises ?','10'), ('Quelle région inspirée de la France sert de cadre à Pokémon X et Y ?','Kalos'), ('Quel reptile change de couleur pour communiquer et se camoufler ?','Le caméléon'), ('Quel jeu de battle royale d''Epic Games est célèbre pour ses danses ?','Fortnite'), ('Qui a remporté le Ballon d''or 2022 ?','Karim Benzema'), ('Quelle région inspirée du Royaume-Uni sert de cadre à Pokémon Épée et Bouclier ?','Galar'), ('Combien de Pokémon comptait la première génération ?','151'), ('Qui a fondé Microsoft avec Paul Allen ?','Bill Gates'), ('Quel cétacé est surnommé « la licorne des mers » ?','Le narval'), ('Quel oiseau est capable de voler en marche arrière ?','Le colibri'), ('De quel pays vient Toyota ?','Le Japon'), ('Quel club a remporté la Ligue des champions en 2025 ?','Le Paris Saint-Germain'), ('Quel club compte le plus de titres de champion de France ?','Le Paris Saint-Germain'), ('Dans quel stade joue le FC Barcelone ?','Le Camp Nou'), ('Quel éditeur français a créé « Assassin''s Creed » ?','Ubisoft'), ('Quel mammifère pond des œufs, comme l''échidné ?','L''ornithorynque'), ('Quel joueur a marqué deux buts de la tête en finale de la Coupe du monde 1998 ?','Zinédine Zidane'), ('Qui est considérée comme la première programmeuse de l''histoire ?','Ada Lovelace'), ('Quel joueur argentin a remporté huit Ballons d''or ?','Lionel Messi'), ('Quel est le jeu vidéo le plus vendu de l''histoire ?','Minecraft'), ('Quel pays a remporté la toute première Coupe du monde, en 1930 ?','L''Uruguay'), ('Quel Pokémon chante pour endormir… puis boude quand on s''endort ?','Rondoudou'), ('Quel Pokémon endormi bloque la route dans Pokémon Rouge et Bleu ?','Ronflex'), ('Quelle course d''endurance dure 24 heures dans la Sarthe ?','Les 24 Heures du Mans'), ('Quel Pokémon a été créé à partir de l''ADN de Mew ?','Mewtwo'), ('Quel est le seul métal liquide à température ambiante ?','Le mercure'), ('Que provoque l''alignement Soleil-Lune-Terre quand la Lune cache le Soleil ?','Une éclipse solaire'), ('Quel dieu manie la foudre grâce à son marteau ?','Thor'), ('Quel savant a énoncé la loi de la gravitation après la chute d''une pomme, selon la légende ?','Isaac Newton'), ('Dans quelle ville française ont eu lieu les JO d''hiver de 1992 ?','Albertville'), ('Quel chimiste russe a créé le tableau périodique en 1869 ?','Dmitri Mendeleïev'), ('Quel empereur a été couronné à Rome le jour de Noël de l''an 800 ?','Charlemagne'), ('Quelle jeune fille a délivré Orléans en 1429 ?','Jeanne d''Arc'), ('Quelle reine d''Égypte a été l''alliée de César puis de Marc Antoine ?','Cléopâtre'), ('Combien d''anneaux compte le drapeau olympique ?','5'), ('Quelle particule de l''atome porte une charge négative ?','L''électron'), ('Quel nageur américain détient le record de médailles d''or olympiques ?','Michael Phelps'), ('Dans quelle ville Jeanne d''Arc a-t-elle été brûlée en 1431 ?','Rouen'), ('Quel acteur incarne Jacquouille la Fripouille dans « Les Visiteurs » ?','Christian Clavier'), ('Quelle est la vitesse de la lumière dans le vide, environ ?','300 000 km/s'), ('Dans quel pays se trouve Olympie, berceau des Jeux antiques ?','La Grèce'), ('Quel chanteur est surnommé « le King » du rock''n''roll ?','Elvis Presley'), ('Quel dieu du vin et de la fête était aussi appelé Bacchus ?','Dionysos'), ('Quel compositeur est devenu sourd mais a continué à composer ?','Ludwig van Beethoven'), ('Quel organe pompe le sang dans tout le corps ?','Le cœur'), ('En quelle année la Seconde Guerre mondiale s''est-elle terminée ?','1945'), ('Quel compositeur polonais a surtout écrit pour le piano ?','Frédéric Chopin'), ('Quel compositeur a écrit « Les Quatre Saisons » ?','Antonio Vivaldi'), ('Quel est le rêve de Luffy ?','Devenir le roi des pirates'), ('Quel instrument à cordes est le plus grand de l''orchestre ?','La contrebasse'), ('En quelle année la Première Guerre mondiale a-t-elle commencé ?','1914'), ('Combien de chromosomes compte une cellule humaine normale ?','46'), ('Quel dieu règne sur les mers ?','Poséidon'), ('Combien de dents compte un adulte en général ?','32'), ('Comment surnommait-on les soldats français de 14-18 ?','Les Poilus'), ('Qui a lancé l''appel du 18 juin 1940 ?','Charles de Gaulle'), ('Quel film Pixar de 2015 se déroule dans la tête d''une petite fille ?','Vice-versa'), ('Qui était le chanteur de Queen ?','Freddie Mercury'), ('Quel héros à la force surhumaine a accompli douze travaux ?','Héraclès'), ('Quel acteur incarne Iron Man dans le MCU ?','Robert Downey Jr.'), ('Quelle chanteuse a sorti « Fallin'' » en 2001 ?','Alicia Keys'), ('Quelle chanteuse a sorti « Kill Bill » en 2022 ?','SZA'), ('Quel artiste a remporté l''Eurovision 2024 avec « The Code » ?','Nemo'), ('Quel chanteur a sorti l''album « Channel Orange » en 2012 ?','Frank Ocean'), ('Quel groupe a sorti l''album « L''École du micro d''argent » en 1997 ?','IAM'), ('Quel morceau de Luis Fonsi et Daddy Yankee a dépassé 8 milliards de vues sur YouTube ?','Despacito'), ('Quel label de Détroit a révélé Stevie Wonder, Marvin Gaye et les Jackson 5 ?','Motown'), ('Quel chanteur belge a sorti « Alors on danse » ?','Stromae'), ('Quel rappeur a sorti l''album « Civilisation » en 2021 ?','Orelsan'), ('Quel rappeur belge a sorti « Batterie faible » et « Ipséité » ?','Damso'), ('Quel chanteur a sorti l''album « Confessions » en 2004 ?','Usher'), ('Quel rappeur a sorti l''album « Ipséité » ?','Damso'), ('Quel réalisateur a tourné « Pulp Fiction » ?','Quentin Tarantino'), ('Quel acteur incarne Jack Sparrow ?','Johnny Depp'), ('Quelle chanteuse a sorti « Drivers License » en 2021 ?','Olivia Rodrigo'), ('Quel duo a sorti « Die With A Smile » en 2024 ?','Lady Gaga et Bruno Mars'), ('Quel groupe de Nekfeu, Alpha Wann et d''autres s''est fait connaître dans les années 2010 ?','1995'), ('Quelle chanteuse a sorti « Levitating » ?','Dua Lipa'), ('Quel chanteur a sorti « What''s Going On » en 1971 ?','Marvin Gaye'), ('Comment s''appelle le passage de l''état solide à l''état liquide ?','La fusion'), ('Quel physicien a énoncé la théorie de la relativité ?','Albert Einstein'), ('Quelle est la formule du sel de cuisine ?','NaCl'), ('Quelle est l''unité de la puissance ?','Le watt'), ('Comment s''appelle le passage de l''état liquide à l''état gazeux ?','La vaporisation'), ('Quelle planète est la plus éloignée du Soleil ?','Neptune'), ('Quel instrument a des touches noires et blanches ?','Le piano'), ('Quel film de Luc Besson (1997) suit Korben Dallas ?','Le Cinquième Élément'), ('Qui dirigeait l''URSS pendant la Seconde Guerre mondiale ?','Joseph Staline'), ('Combien de cordes a un violon ?','4'), ('Dans quel pays se trouve la ville de Marrakech ?','Le Maroc'), ('Combien de notes compte la gamme de do majeur (sans répéter le do) ?','7'), ('Quel festival de musique se tient chaque année à Carhaix, en Bretagne ?','Les Vieilles Charrues'), ('Quel pays possède le plus d''habitants en Afrique ?','Le Nigeria'), ('Quel pays a remporté la Coupe du monde 2022 ?','L''Argentine'), ('Comment s''appelle le satellite naturel de la Terre ?','La Lune'), ('Combien de joueurs compte une équipe de football sur le terrain ?','11'), ('Quel est le plus grand désert froid du monde ?','L''Antarctique'), ('Quel pilote néerlandais a remporté quatre titres consécutifs de 2021 à 2024 ?','Max Verstappen'), ('Quel est le pays le plus peuplé du monde depuis 2023 ?','L''Inde'), ('Combien de temps dure un match de football (hors prolongations) ?','90 minutes'), ('Combien de secondes compte une heure ?','3 600'), ('Dans quel sport parle-t-on de « strike » en renversant toutes les quilles ?','Le bowling'), ('Quel traité a créé la Communauté économique européenne en 1957 ?','Le traité de Rome'), ('Quel est le dernier Français vainqueur du Tour de France, en 1985 ?','Bernard Hinault'), ('Quelle force nous fait tomber vers le sol ?','La gravité'), ('Quelle épice donne sa couleur jaune au curry et au riz ?','Le curcuma'), ('Quel fromage est indispensable dans une tartiflette ?','Le reblochon'), ('Quel sport pratique le Français Victor Wembanyama ?','Le basket-ball'), ('Quel chef français était surnommé « le pape de la gastronomie » ?','Paul Bocuse'), ('Dans quel sport s''illustre Tony Parker ?','Le basket-ball'), ('Dans quel sport frappe-t-on un volant avec une raquette ?','Le badminton'), ('Qui fut le premier président des États-Unis ?','George Washington'), ('Quel scientifique français a mis au point le vaccin contre la rage ?','Louis Pasteur'), ('Quelle bataille de 1815 marque la défaite finale de Napoléon ?','Waterloo'), ('Quel ingrédient fait lever la pâte à pain ?','La levure'), ('Quel gaz les plantes absorbent-elles pour faire la photosynthèse ?','Le dioxyde de carbone'), ('Quel pasteur a prononcé le discours « I have a dream » en 1963 ?','Martin Luther King'), ('Quelle fête célèbre-t-on le 14 juillet en France ?','La fête nationale'), ('Quel roi de France était surnommé « le Roi-Soleil » ?','Louis XIV'), ('Quel mur est tombé en 1989 ?','Le mur de Berlin'), ('Combien de joueurs compte une équipe de rugby à XV sur le terrain ?','15'), ('Quel animal est le symbole de la France ?','Le coq'), ('Quelle épice est la plus chère du monde au poids ?','Le safran'), ('Quel gâteau breton est très riche en beurre ?','Le kouign-amann'), ('Quel surnom porte l''équipe de Nouvelle-Zélande de rugby ?','Les All Blacks'), ('De quel pays vient la paella ?','L''Espagne'), ('Quel est l''état de l''eau sous forme de glace ?','Solide'), ('De quel pays vient le kimchi ?','La Corée'), ('Quelle reine, épouse de Louis XVI, a été guillotinée ?','Marie-Antoinette'), ('Quel savant a établi la théorie de l''évolution par la sélection naturelle ?','Charles Darwin'), ('Quel nageur français a remporté 4 titres olympiques individuels à Paris 2024 ?','Léon Marchand'), ('Quel est l''hymne national français ?','La Marseillaise'), ('En quelle année l''Algérie a-t-elle obtenu son indépendance ?','1962'), ('Quel est le symbole de la paix ?','La colombe'), ('Quel médecin a découvert la pénicilline en 1928 ?','Alexander Fleming'), ('En quelle année les femmes ont-elles voté pour la première fois en France ?','1945'), ('Quel empereur français a été exilé à Sainte-Hélène ?','Napoléon Ier'), ('Quelle chanteuse a sorti l''album « SOS » en 2022 ?','SZA'), ('Quel peintre a réalisé « La Jeune Fille à la perle » ?','Johannes Vermeer'), ('Quelle série française suit des agents d''acteurs dans une agence parisienne ?','Dix pour cent'), ('Quel peintre a réalisé « La Liberté guidant le peuple » ?','Eugène Delacroix'), ('Qui a écrit « Harry Potter » ?','J. K. Rowling'), ('Quel artiste du pop art a peint des boîtes de soupe Campbell''s ?','Andy Warhol'), ('Que veut dire « poser un lapin » ?','Ne pas venir à un rendez-vous'), ('Quelle étoile indique le pôle Nord céleste ?','L''étoile polaire'), ('Quelle série animée met en scène une famille jaune de Springfield ?','Les Simpson'), ('Dans quel café se retrouvent les personnages de « Friends » ?','Central Perk'), ('Quel est le type de Pikachu ?','Électrik'), ('Quel est le Pokémon légendaire mascotte de Pokémon Or ?','Ho-Oh'), ('Quel jeu oppose des voitures qui jouent au football ?','Rocket League'), ('Quel DJ français a sorti « Titanium » avec Sia ?','David Guetta'), ('En quoi évolue Évoli avec une Pierre Eau ?','Aquali'), ('Quel peintre a réalisé « La Ronde de nuit » ?','Rembrandt'), ('Quel peintre pointilliste a réalisé « Un dimanche après-midi à l''île de la Grande Jatte » ?','Georges Seurat'), ('Quel chanteur a sorti « Blinding Lights », la chanson la plus écoutée de Spotify ?','The Weeknd'), ('Dans « La casa de papel », qui est le cerveau du braquage ?','Le Professeur'), ('Quel héros français sans bras ni jambes a été créé par Michel Ancel ?','Rayman'), ('Quel dieu égyptien est représenté avec une tête de chacal ?','Anubis'), ('Quelle chanteuse française a sorti « Dernière danse » en 2013 ?','Indila'), ('Quel peintre espagnol aux moustaches extravagantes a peint des montres molles ?','Salvador Dalí'), ('Quel chanteur a sorti l''album « Blonde » en 2016 ?','Frank Ocean'), ('Quel peintre a réalisé « Le Déjeuner sur l''herbe » (1863) ?','Édouard Manet'), ('Quelle chanteuse a sorti « No Scrubs » avec son groupe en 1999 ?','TLC'), ('Quel street artiste britannique garde son identité secrète ?','Banksy'), ('Quel peintre autrichien a réalisé « Le Baiser » doré ?','Gustav Klimt')) as v(question, answer) where q.question = v.question and q.answer = v.answer;

create or replace function public.pick_questions(p_theme text, p_user uuid, p_n int default 10) returns bigint[]
language sql volatile security definer set search_path = public as $$
  select array_agg(id order by difficulty, r) from (
    select q.id, q.difficulty, random() r
      from public.questions q
      left join public.seen_questions s on s.question_id = q.id and s.user_id = p_user
     where q.theme = any(public.theme_family(p_theme)) and q.active
     order by (s.seen_at is not null),
              row_number() over (partition by q.theme order by s.seen_at nulls first, random()),
              random()
     limit greatest(5, least(coalesce(p_n, 10), 20))) x;
$$;

create or replace function public.start_live(p_theme text, p_private boolean, p_n int) returns jsonb
language plpgsql security definer set search_path = public as $$
declare me uuid := auth.uid(); mid uuid; qids bigint[]; n int := greatest(5, least(coalesce(p_n, 10), 20));
begin
  if me is null then raise exception 'non connecté'; end if;
  if not p_private then
    select id into mid from public.matches
     where theme = p_theme and live and not private and p1 <> me and p2 is null and p1_answers is null
       and array_length(question_ids, 1) = n
       and created_at > now() - interval '25 seconds'
     order by created_at limit 1 for update skip locked;
    if mid is not null then
      update public.matches set p2 = me, p2_joined_at = now() where id = mid;
      return public.match_payload(mid);
    end if;
  end if;
  qids := public.pick_questions(p_theme, me, n);
  if qids is null or array_length(qids, 1) < least(n, 7) then raise exception 'pas assez de questions pour ce thème'; end if;
  insert into public.matches(theme, question_ids, p1, private, live)
  values (p_theme, qids, me, p_private, true) returning id into mid;
  return public.match_payload(mid);
end $$;

create or replace function public.start_match(p_theme text, p_private boolean, p_n int) returns jsonb
language plpgsql security definer set search_path = public as $$
declare me uuid := auth.uid(); mid uuid; qids bigint[]; n int := greatest(5, least(coalesce(p_n, 10), 20));
begin
  if me is null then raise exception 'non connecté'; end if;
  if not p_private then
    select id into mid from public.matches
     where theme = p_theme and not private and not live and p1 <> me
       and p1_answers is not null and p2_answers is null
       and array_length(question_ids, 1) = n
       and (p2 is null or p2 = me or p2_joined_at < now() - interval '10 minutes')
     order by created_at limit 1 for update skip locked;
    if mid is not null then
      update public.matches set p2 = me, p2_joined_at = now() where id = mid;
      return public.match_payload(mid);
    end if;
  end if;
  qids := public.pick_questions(p_theme, me, n);
  if qids is null or array_length(qids, 1) < least(n, 7) then raise exception 'pas assez de questions pour ce thème'; end if;
  insert into public.matches(theme, question_ids, p1, private) values (p_theme, qids, me, p_private) returning id into mid;
  return public.match_payload(mid);
end $$;
grant execute on function public.start_live(text, boolean, int), public.start_match(text, boolean, int) to authenticated;
commit;

CREATE OR REPLACE FUNCTION public.submit_solo(p_id uuid, p_theme text, p_difficulty integer, p_qids bigint[], p_answers jsonb, p_played_at timestamp with time zone)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare me uuid := auth.uid(); sc int; ok int; gain int; n int;
begin
  if me is null then raise exception 'non connecté'; end if;
  if exists (select 1 from public.solo_games where id = p_id) then
    return jsonb_build_object('duplicate', true);
  end if;
  if array_length(p_qids, 1) is null or array_length(p_qids, 1) not between 5 and 20
     or jsonb_typeof(p_answers) <> 'array' or jsonb_array_length(p_answers) <> array_length(p_qids, 1) then
    raise exception 'partie invalide';
  end if;
  select count(*) into n from public.questions where id = any(p_qids) and theme = any(public.theme_family(p_theme));
  if n <> array_length(p_qids, 1) then raise exception 'questions invalides'; end if;
  select count(*) into n from public.solo_games where user_id = me and synced_at > now() - interval '1 day';
  if n >= 60 then raise exception 'limite de parties solo atteinte pour aujourd''hui'; end if;
  if p_played_at > now() + interval '5 minutes' or p_played_at < now() - interval '30 days' then
    p_played_at := now();
  end if;
  sc := public.score_answers(p_qids, p_answers);
  select count(*) into ok
    from unnest(p_qids) with ordinality u(qid, i) join public.questions q on q.id = u.qid
   where p_answers -> (u.i::int - 1) ->> 'c' = q.answer;
  gain := round(sc / 2.0);
  insert into public.solo_games(id, user_id, theme, difficulty, question_ids, answers, score, correct, played_at)
  values (p_id, me, p_theme, greatest(1, least(3, coalesce(p_difficulty, 1))), p_qids, p_answers, sc, ok, p_played_at);
  perform public.add_stats(me, p_theme, gain, sc, 1, 0, 0, 0);
  return jsonb_build_object('score', sc, 'correct', ok, 'xp', gain);
end $function$

;
-- Défi Quiz · phase24b : vague de questions (100)
begin;
insert into public.questions(theme, difficulty, question, answer, wrong)
select v.theme, v.difficulty, v.question, v.answer, v.wrong from (values
('egyptienne',1,'Quel dieu égyptien est le dieu des morts et de l''au-delà, représenté en momie verte ?','Osiris',array['Râ','Horus','Seth']::text[]),
('egyptienne',1,'Quelle déesse égyptienne à tête de vache est celle de l''amour et de la musique ?','Hathor',array['Isis','Bastet','Sekhmet']::text[]),
('egyptienne',1,'Quel insecte sacré représentait le soleil levant en Égypte ?','Le scarabée',array['L''abeille','La mante religieuse','La libellule']::text[]),
('egyptienne',1,'Quelle créature à corps de lion et tête humaine garde le plateau de Gizeh ?','Le Sphinx',array['La Chimère','Le griffon','La manticore']::text[]),
('egyptienne',2,'Quel symbole en forme de croix à boucle représente la vie éternelle ?','L''ânkh',array['L''œil d''Horus','Le djed','Le was']::text[]),
('egyptienne',2,'Quelle déesse lionne incarne la colère destructrice de Râ ?','Sekhmet',array['Bastet','Hathor','Mout']::text[]),
('egyptienne',2,'Quel dieu à tête de bélier façonnait les humains sur un tour de potier ?','Khnoum',array['Amon','Ptah','Min']::text[]),
('egyptienne',2,'Quel dieu créateur était vénéré à Memphis, patron des artisans ?','Ptah',array['Amon','Atoum','Khonsou']::text[]),
('egyptienne',2,'Quelle déesse au corps couvert d''étoiles représente le ciel ?','Nout',array['Geb','Shou','Tefnout']::text[]),
('egyptienne',2,'Quel dieu représente la terre, frère et époux de Nout ?','Geb',array['Shou','Atoum','Seth']::text[]),
('egyptienne',2,'Quel serpent géant attaque chaque nuit la barque de Râ ?','Apophis',array['Ouadjet','Mehen','Nehebkaou']::text[]),
('egyptienne',2,'Quel symbole protecteur représente l''œil du dieu faucon ?','L''Oudjat (œil d''Horus)',array['L''ânkh','Le scarabée','Le sistre']::text[]),
('egyptienne',3,'Quelle déesse cobra protège la Basse-Égypte ?','Ouadjet',array['Nekhbet','Renenoutet','Mertseger']::text[]),
('egyptienne',3,'Quelle déesse vautour protège la Haute-Égypte ?','Nekhbet',array['Ouadjet','Mout','Nephthys']::text[]),
('egyptienne',3,'Quel dieu de Thèbes a été fusionné avec Râ ?','Amon',array['Ptah','Montou','Atoum']::text[]),
('egyptienne',3,'Comment s''appelle le monstre mi-crocodile, mi-lion, mi-hippopotame qui dévore les cœurs impurs ?','Ammit',array['Apophis','Taouret','Sobek']::text[]),
('egyptienne',3,'Quelle déesse hippopotame protège les femmes enceintes ?','Taouret',array['Hathor','Heqet','Meskhenet']::text[]),
('egyptienne',3,'Quelle sœur d''Isis est l''épouse de Seth et la mère d''Anubis ?','Nephthys',array['Nout','Tefnout','Hathor']::text[]),
('egyptienne',3,'Quel texte funéraire guidait les défunts dans l''au-delà ?','Le Livre des morts',array['Le Livre des rois','Les Textes de l''Ennéade','Le Papyrus de Rhind']::text[]),
('egyptienne',3,'Comment s''appelle le groupe des neuf dieux d''Héliopolis ?','L''Ennéade',array['L''Ogdoade','La Triade','Le Panthéon']::text[]),
('romaine',1,'Quels jumeaux ont été allaités par une louve selon la légende de Rome ?','Romulus et Rémus',array['Castor et Pollux','Énée et Ascagne','Apollon et Diane']::text[]),
('romaine',1,'Lequel des jumeaux a fondé Rome ?','Romulus',array['Rémus','Énée','Numa']::text[]),
('romaine',1,'Quelle déesse romaine est l''épouse de Jupiter ?','Junon',array['Vénus','Minerve','Diane']::text[]),
('romaine',1,'Quel petit dieu ailé de l''amour tire des flèches ?','Cupidon',array['Mercure','Bacchus','Apollon']::text[]),
('romaine',2,'Quel est le nom romain de Dionysos ?','Bacchus',array['Saturne','Mercure','Liber Pater']::text[]),
('romaine',2,'Quel est le nom romain de Déméter, déesse des moissons ?','Cérès',array['Vesta','Flore','Junon']::text[]),
('romaine',2,'Quel est le nom romain d''Hadès ?','Pluton',array['Saturne','Vulcain','Janus']::text[]),
('romaine',2,'Quelle déesse romaine du foyer était gardée par des prêtresses vierges ?','Vesta',array['Cérès','Junon','Diane']::text[]),
('romaine',2,'Quel dieu romain, assimilé à Cronos, a donné son nom au samedi anglais ?','Saturne',array['Janus','Pluton','Mars']::text[]),
('romaine',2,'Quel héros troyen est l''ancêtre légendaire des Romains ?','Énée',array['Hector','Pâris','Priam']::text[]),
('romaine',2,'Quel poète latin a écrit « L''Énéide » ?','Virgile',array['Ovide','Horace','Homère']::text[]),
('romaine',2,'Quel poète latin a écrit « Les Métamorphoses » ?','Ovide',array['Virgile','Catulle','Sénèque']::text[]),
('romaine',3,'Comment appelait-on les esprits protecteurs du foyer romain ?','Les Lares',array['Les Mânes','Les Lémures','Les Génies']::text[]),
('romaine',3,'Quelle fête romaine de décembre renversait les rôles entre maîtres et esclaves ?','Les Saturnales',array['Les Lupercales','Les Floralies','Les Bacchanales']::text[]),
('romaine',3,'Quel roi légendaire de Rome a instauré les rites religieux avec la nymphe Égérie ?','Numa Pompilius',array['Tarquin le Superbe','Servius Tullius','Ancus Marcius']::text[]),
('romaine',3,'Quelle jeune femme romaine a trahi Rome pour des bracelets d''or, selon la légende ?','Tarpéia',array['Lucrèce','Virginie','Hersilie']::text[]),
('romaine',3,'Quelle déesse romaine de l''aurore correspond à Éos ?','Aurore',array['Luna','Flore','Fortuna']::text[]),
('romaine',3,'Quelle déesse romaine du hasard tourne une roue ?','Fortuna',array['Victoria','Bellone','Némésis']::text[]),
('romaine',3,'Quel dieu romain des frontières était représenté par une simple borne ?','Terminus',array['Janus','Portunus','Silvain']::text[]),
('celtique',1,'Quel roi légendaire réunit ses chevaliers autour de la Table ronde ?','Arthur',array['Lancelot','Merlin','Mordred']::text[]),
('celtique',1,'Quel objet sacré les chevaliers de la Table ronde recherchent-ils ?','Le Saint Graal',array['L''Arche d''alliance','La Toison d''or','Le Bouclier d''Achille']::text[]),
('celtique',1,'Quel peuple antique avait des prêtres appelés druides ?','Les Celtes',array['Les Romains','Les Vikings','Les Grecs']::text[]),
('celtique',1,'Quelle plante les druides cueillaient-ils avec une serpe d''or ?','Le gui',array['Le houx','Le lierre','Le chêne']::text[]),
('celtique',1,'Quel petit être de l''Irlande garde un chaudron d''or au pied de l''arc-en-ciel ?','Le leprechaun',array['Le korrigan','Le farfadet','Le troll']::text[]),
('celtique',2,'Quel chevalier de la Table ronde est l''amant de la reine Guenièvre ?','Lancelot',array['Gauvain','Perceval','Galaad']::text[]),
('celtique',2,'Quel chevalier pur trouve finalement le Graal ?','Galaad',array['Lancelot','Gauvain','Keu']::text[]),
('celtique',2,'Dans quelle île mystérieuse Arthur est-il emmené après sa dernière bataille ?','Avalon',array['Tintagel','Lyonesse','Brocéliande']::text[]),
('celtique',2,'Dans quelle forêt bretonne Merlin aurait-il été enchanté par Viviane ?','Brocéliande',array['Avalon','Tintagel','Carnac']::text[]),
('celtique',2,'Quelle fée, demi-sœur d''Arthur, est une puissante magicienne ?','Morgane',array['Viviane','Mélusine','Guenièvre']::text[]),
('celtique',2,'Quelle fête celte de fin octobre est l''ancêtre d''Halloween ?','Samain',array['Beltaine','Imbolc','Lugnasad']::text[]),
('celtique',2,'Quels petits lutins farceurs dansent la nuit dans les légendes bretonnes ?','Les korrigans',array['Les gnomes','Les elfes noirs','Les trolls']::text[]),
('celtique',2,'Quelle fée mi-femme mi-serpent est liée à la famille de Lusignan ?','Mélusine',array['Morgane','Viviane','Niniane']::text[]),
('celtique',3,'Quel dieu celte aux multiples talents a donné son nom à Lyon (Lugdunum) ?','Lug',array['Dagda','Cernunnos','Belenos']::text[]),
('celtique',3,'Quel dieu celte porte des bois de cerf ?','Cernunnos',array['Lug','Taranis','Teutatès']::text[]),
('celtique',3,'Quel dieu gaulois du tonnerre est associé à une roue ?','Taranis',array['Teutatès','Ésus','Bélénos']::text[]),
('celtique',3,'Quel dieu irlandais possède un chaudron inépuisable et une massue ?','Le Dagda',array['Lug','Nuada','Manannán']::text[]),
('celtique',3,'Quel peuple divin a régné sur l''Irlande avant les humains ?','Les Tuatha Dé Danann',array['Les Fomoires','Les Fir Bolg','Les Milésiens']::text[]),
('celtique',3,'Quelle ville légendaire bretonne a été engloutie par les flots ?','Ys',array['Avalon','Lyonesse','Camelot']::text[]),
('celtique',3,'Quel recueil gallois du Moyen Âge rassemble des récits mythologiques ?','Le Mabinogion',array['Le Kalevala','Le Livre de Leinster','L''Edda']::text[]),
('celtique',3,'Dans quel château vit le roi Arthur ?','Camelot',array['Tintagel','Avalon','Carduel']::text[]),
('asiatique',1,'Quel singe magique accompagne un moine dans « La Pérégrination vers l''Ouest » ?','Sun Wukong (le Roi Singe)',array['Hanuman','Zhu Bajie','Sha Wujing']::text[]),
('asiatique',1,'Quel animal légendaire chinois, symbole de l''empereur, est bienveillant et apporte la pluie ?','Le dragon',array['Le phénix','Le tigre blanc','La tortue noire']::text[]),
('asiatique',1,'Dans quel pays vénère-t-on des esprits appelés kami ?','Le Japon',array['La Chine','La Corée','L''Inde']::text[]),
('asiatique',1,'Quel dieu hindou est le destructeur et le transformateur ?','Shiva',array['Vishnou','Brahmā','Indra']::text[]),
('asiatique',1,'Quel dieu-singe hindou est le fidèle serviteur de Rāma ?','Hanuman',array['Ganesh','Sun Wukong','Garuda']::text[]),
('asiatique',2,'Quelle épopée indienne raconte l''histoire de Rāma et Sītā ?','Le Râmâyana',array['Le Mahâbhârata','Les Védas','Les Upanishads']::text[]),
('asiatique',2,'Quelle épopée indienne contient la Bhagavad-Gîtâ ?','Le Mahâbhârata',array['Le Râmâyana','Les Védas','Le Kalevala']::text[]),
('asiatique',2,'Quelle déesse hindoue aux nombreux bras combat le démon-buffle ?','Durgā',array['Lakshmi','Sarasvatî','Parvati']::text[]),
('asiatique',2,'Quel dieu shintoïste de la tempête est le frère d''Amaterasu ?','Susanoo',array['Tsukuyomi','Izanagi','Raijin']::text[]),
('asiatique',2,'Quel dieu japonais du tonnerre est représenté avec des tambours ?','Raijin',array['Fujin','Susanoo','Hachiman']::text[]),
('asiatique',2,'Quelle créature aquatique japonaise a une cavité d''eau sur la tête ?','Le kappa',array['Le tengu','Le tanuki','L''oni']::text[]),
('asiatique',2,'Quel oiseau-homme japonais vit dans les montagnes et a un long nez ?','Le tengu',array['Le kappa','Le kitsune','Le baku']::text[]),
('asiatique',2,'Quel monstre japonais rouge ou bleu à cornes porte une massue ?','L''oni',array['Le kappa','Le yūrei','Le tengu']::text[]),
('asiatique',3,'Quel couple divin a créé l''archipel japonais avec une lance ?','Izanagi et Izanami',array['Amaterasu et Susanoo','Raijin et Fujin','Ninigi et Konohanasakuya']::text[]),
('asiatique',3,'Quel oiseau géant est la monture de Vishnou ?','Garuda',array['Jatayu','Hamsa','Simurgh']::text[]),
('asiatique',3,'Quelle déesse chinoise vit sur la Lune avec un lapin de jade ?','Chang''e',array['Nüwa','Guanyin','Xiwangmu']::text[]),
('asiatique',3,'Quelle déesse chinoise a créé les humains avec de l''argile jaune ?','Nüwa',array['Chang''e','Mazu','Guanyin']::text[]),
('asiatique',3,'Quel empereur légendaire chinois est appelé l''« Empereur jaune » ?','Huangdi',array['Yu le Grand','Shennong','Fuxi']::text[]),
('asiatique',3,'Quel dieu védique du tonnerre est le roi des dieux dans les Védas ?','Indra',array['Agni','Varuna','Surya']::text[]),
('asiatique',3,'Quel dieu védique est le dieu du feu ?','Agni',array['Indra','Soma','Vayu']::text[]),
('precolombienne',1,'Quel peuple a fondé Tenochtitlan, sur l''actuelle Mexico ?','Les Aztèques',array['Les Mayas','Les Incas','Les Olmèques']::text[]),
('precolombienne',1,'Quel peuple d''Amérique du Sud a bâti le Machu Picchu ?','Les Incas',array['Les Aztèques','Les Mayas','Les Toltèques']::text[]),
('precolombienne',1,'Quel peuple d''Amérique centrale est célèbre pour son calendrier et ses pyramides comme Chichén Itzá ?','Les Mayas',array['Les Incas','Les Aztèques','Les Mapuches']::text[]),
('precolombienne',1,'Quelle déesse inca représente la Terre-Mère ?','Pachamama',array['Mama Quilla','Coatlicue','Ixchel']::text[]),
('precolombienne',2,'Quel livre sacré raconte la création du monde selon les Mayas quichés ?','Le Popol Vuh',array['Le Codex Mendoza','Le Chilam Balam','Le Codex Borgia']::text[]),
('precolombienne',2,'Quel serpent à plumes est appelé Kukulcán chez les Mayas ?','Quetzalcóatl',array['Tezcatlipoca','Xiuhcoatl','Tláloc']::text[]),
('precolombienne',2,'Quel dieu aztèque du « miroir fumant » est le rival de Quetzalcóatl ?','Tezcatlipoca',array['Huitzilopochtli','Tláloc','Mictlantecuhtli']::text[]),
('precolombienne',2,'Quel dieu aztèque règne sur Mictlan, le monde des morts ?','Mictlantecuhtli',array['Tezcatlipoca','Xólotl','Tláloc']::text[]),
('precolombienne',2,'Quel dieu créateur inca serait sorti du lac Titicaca ?','Viracocha',array['Inti','Pachacamac','Illapa']::text[]),
('precolombienne',2,'Quelle déesse inca représente la Lune ?','Mama Quilla',array['Pachamama','Mama Cocha','Ixchel']::text[]),
('precolombienne',2,'Quels jumeaux héros affrontent les seigneurs de l''inframonde dans le Popol Vuh ?','Hunahpú et Xbalanqué',array['Romulus et Rémus','Castor et Pollux','Quetzalcóatl et Xólotl']::text[]),
('precolombienne',2,'Quelle légende annonçait le lieu où fonder Tenochtitlan ?','Un aigle sur un cactus dévorant un serpent',array['Un jaguar sur un rocher','Un condor dans un lac','Un serpent à plumes dans le ciel']::text[]),
('precolombienne',3,'Quelle déesse aztèque à la jupe de serpents est la mère de Huitzilopochtli ?','Coatlicue',array['Coyolxauhqui','Chalchiuhtlicue','Tonantzin']::text[]),
('precolombienne',3,'Quelle déesse aztèque démembrée a donné naissance à la Lune ?','Coyolxauhqui',array['Coatlicue','Xochiquetzal','Mayahuel']::text[]),
('precolombienne',3,'Quel dieu aztèque de l''agriculture se couvrait de peau humaine écorchée ?','Xipe Totec',array['Tláloc','Centéotl','Xólotl']::text[]),
('precolombienne',3,'Quel dieu maya de la pluie porte une hache-éclair ?','Chaac',array['Itzamná','Kinich Ahau','Ah Puch']::text[]),
('precolombienne',3,'Comment s''appelle l''inframonde maya ?','Xibalba',array['Mictlan','Tlalocan','Uku Pacha']::text[]),
('precolombienne',3,'Quel chien divin aztèque accompagne les morts vers Mictlan ?','Xólotl',array['Ahuízotl','Nahual','Cipactli']::text[]),
('precolombienne',3,'Quelle déesse aztèque de l''eau est l''épouse de Tláloc ?','Chalchiuhtlicue',array['Coatlicue','Xochiquetzal','Mayahuel']::text[]),
('precolombienne',3,'Quelle déesse maya est associée à la Lune, au tissage et aux naissances ?','Ixchel',array['Mama Quilla','Coatlicue','Xtabay']::text[])
) as v(theme, difficulty, question, answer, wrong)
where not exists (select 1 from public.questions q where q.question = v.question and q.answer = v.answer);
commit;
