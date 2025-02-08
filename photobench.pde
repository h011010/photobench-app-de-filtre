PImage img,icon0,icon1,icon2,icon3,icon4,icon5,icon6,icon7;
float imageLargeur,imageHauteur;  // pour gerer  largeur et hauteur de l'image
float positionImgX = 150, positionImgY = 0;  // Position de l'image
String NomDuboutonActif = "";  // pour le nom de outil actuellement sélectionné
boolean isDragging = false;  // Indique si la souris est en train de dessiner une sélection
int x1, y1, x2, y2;        // Coordonnées de la zone sélectionnée

// Historique des états d'image pour Undo/Redo
ArrayList<PImage> undoMemoire = new ArrayList<PImage>();
ArrayList<PImage> redoMemoire = new ArrayList<PImage>();

float zoomFactor = 1.0;  // le Facteur pour augmenter et diminuer le zoom
boolean imgBouge = false;  // variable qui signal si l'image est en train d'être déplacée
float precedantMouseX, precedantMouseY;  // Position de la souris précédente pour déplacer l'image

void setup(){
 size (800,600); 
 // Charger l'image principale
 img=loadImage("escargorille.jpg");
  // charger mes icones
  icon0=loadImage("retouche.jpg");
  icon1=loadImage("select rectangle.png");
  icon2=loadImage("deselect.png");
  icon3=loadImage("undo.jpg");
  icon4=loadImage("redo.png");
  icon5=loadImage("zoom+.jpg");
  icon6=loadImage("zoom-png-9.jpg");
  icon7=loadImage("enregistrer.png");
}


void draw(){
 background(220);
 // zone pour la barre d'outils et les boutons
  fill(20, 100, 200);
  noStroke();
  rect(0, 0, 150, height);
 // zone de l'image
 imageLargeur = img.width*zoomFactor ;
 imageHauteur = img.height*zoomFactor;
 image(img, positionImgX, positionImgY, imageLargeur, imageHauteur);
  dessinerBouton("Blur", 10, 40, icon0); // on appel la fonction dessinerBouton dans draw()
  dessinerBouton("Invert", 10, 80,icon0);
  dessinerBouton("Grayscale", 10, 120,icon0);
  dessinerBouton("Select", 10, 160, icon1);
  dessinerBouton("Deselect", 10, 200,icon2);
  dessinerBouton("Undo", 10, 240,icon3);
  dessinerBouton("Redo", 10, 280,icon4);
  dessinerBouton("Zoom In", 10, 320,icon5);
  dessinerBouton("Zoom Out", 10, 360,icon6);
  dessinerBouton("Drag", 10, 400,icon0 );
  dessinerBouton("save", 10, 440,icon7);
  dessinerBouton("CerSelect", 10,480,icon0);
  
   montrerZoneActiveSelect(); // Montrer la zone de sélection si active
}
//#####################################################################################################################################################################################
//#####################################################################################################################################################################################
//#####################################################################################################################################################################################
              // les ecouteurs d'événement
              
              
void mousePressed() {
  // Si la zone des outils est cliquée
  if (mouseX < 150) {
    if (mouseY > 40 && mouseY < 70) NomDuboutonActif = "Blur";
    else if (mouseY > 80 && mouseY < 110) NomDuboutonActif = "Invert";
    else if (mouseY > 120 && mouseY < 150) NomDuboutonActif = "Grayscale";
    else if (mouseY > 160 && mouseY < 190) NomDuboutonActif = "Select";
    else if (mouseY > 200 && mouseY < 230) deselect();  // Bouton Deselect
    else if (mouseY > 240 && mouseY < 270) undo(); // Bouton Undo
    else if (mouseY > 280 && mouseY < 310) redo();  // Bouton Redo
    else if (mouseY > 320 && mouseY < 350) zoomPlus() ;  // Bouton Zoom ++
    else if (mouseY > 360 && mouseY < 390) zoomMoins(); // Bouton Zoom --
    else if (mouseY > 400 && mouseY < 430) NomDuboutonActif = "Drag" ; // Bouton Drag
    else if (mouseY > 440 && mouseY < 470) enregistrerJpg(); // bouton pour enrégistrer l'image
    else if (mouseY > 480 && mouseY < 510) ;  // pour la selection en cercle
  } // Début de la sélection de zone
  else if (NomDuboutonActif.equals("Select")) {
    x1 = constrain(mouseX, 150, width); // Limite de la zone d'image entre 150 et width pour ne pas toucher la barre de tâche
    y1 = constrain(mouseY, 0, height);
    x2 = x1;
    y2 = y1;
    isDragging = true;
  } else if (NomDuboutonActif.equals("Drag") && mouseX > 150 && mouseX < width && mouseY > 0) {
    imgBouge = true;
    precedantMouseX = mouseX;
    precedantMouseY = mouseY;
  }
}
                      //*****************************************************************************************************************************************

 void mouseDragged() {
 
  if (NomDuboutonActif.equals("Select") && isDragging==true) {
    x2 = constrain(mouseX, 150, width); // Limite de la zone de mobilité de l'image
    y2 = constrain(mouseY, 0, height);
  }
    // Déplacer l'image lorsque l'outil "Drag" est activé
  if (NomDuboutonActif.equals("Drag") && imgBouge==true) {
    float deltaX = mouseX - precedantMouseX;
    float deltaY = mouseY - precedantMouseY;
    positionImgX += deltaX;
    positionImgY += deltaY;
    if (positionImgX < 150) {
      positionImgX = 150;  // Limiter la position X de l'image pour qu'elle ne parte pas derrière la barre d'outils
    }
   precedantMouseX = mouseX;
   precedantMouseY = mouseY;
  }
  
  
}
 
                     //*****************************************************************************************************************************************

void mouseReleased() {
  // Terminer la sélection ou le déplacement
  if (NomDuboutonActif.equals("Select")) {
    isDragging = false;
    appliquerFiltre(NomDuboutonActif);  // Appliquer le filtre lorsque la sélection est terminée
  } else if (!NomDuboutonActif.equals("")) {
    appliquerFiltre(NomDuboutonActif);  // Appliquer l'outil si sélectionné
  }else if (NomDuboutonActif.equals("Drag")) {
    imgBouge = false;  // Arrêter le drag de l'image
  }
}

                    //*****************************************************************************************************************************************

void keyPressed() {
  // Vérifier si la touche pressée est la touche Backspace
  if (key == BACKSPACE) {
    undo();  // Appeler la fonction undo pour annuler la dernière modification
  }
} 


//#####################################################################################################################################################################################
//#####################################################################################################################################################################################
//#####################################################################################################################################################################################
                //les fonctions

// Fonction pour dessiner les bouton
void dessinerBouton(String label, int x, int y, PImage icon) {
  
    // Ajouter une couleur rouge transparente quand l'outil est actif
  if (NomDuboutonActif.equals(label)) {
    fill(255, 0, 0);  // donne une couleur rouge quand on click
  } else {
    fill(200);  // Gris clair
  }
  rect(x, y, 120, 30);
  
  image(icon,x,y,60,30);
  
  fill(0);
  text(label, 75, y + 20);
}



// Appliquer l'outil sélectionné uniquement à la zone choisie ou à toute l'image
void appliquerFiltre(String tool) {
 
  // Sauvegarder l'état de l'image dans l'historique des "undo" avant de modifier l'image
  sauvegardeUndo();
  
  // Si la sélection n'est pas active (aucune sélection rectangulaire), appliquer à toute l'image
  if (x1 == x2 && y1 == y2) {
    // Appliquer l'effet à toute l'image
    if (tool.equals("Blur")) {
      img.filter(BLUR, 3);
    } else if (tool.equals("Invert")) {
      img.filter(INVERT);
    } else if (tool.equals("Grayscale")) {
      img.filter(GRAY);
    }
  } else {
    // Si une sélection a été faite, appliquer l'effet seulement à la zone sélectionnée
    int startX = int((min(x1, x2) - positionImgX)/zoomFactor ); //ici on ajuster en divisant par le facteur pour tenir compte du zoom
    int startY = int((min(y1, y2) - positionImgY)/zoomFactor );
    int width = int(abs(x2 - x1)/zoomFactor );
    int height = int(abs(y2 - y1)/zoomFactor);

    // Vérifier si une zone est bien sélectionnée
    if (width > 0 && height > 0) {
      PImage zoneDeSelection = img.get(startX, startY, width, height);  // Extraire la zone sélectionnée

      // Appliquer le filtre à la zone sélectionnée
      if (tool.equals("Blur")) {
       zoneDeSelection.filter(BLUR, 3);
      } else if (tool.equals("Invert")) {
        zoneDeSelection.filter(INVERT);
      } else if (tool.equals("Grayscale")) {
        zoneDeSelection.filter(GRAY);
      }

      // Réintégrer la zone modifiée dans l'image
      img.set(startX, startY, zoneDeSelection);
    }
  }
}

                    //*****************************************************************************************************************************************
                    
// Montrer la zone de sélection si active en rouge
  void montrerZoneActiveSelect(){
    if (isDragging==true || (x1 != x2 && y1 != y2)) {
    noFill();
    stroke(255, 0, 0);
    rect(x1, y1, x2 - x1, y2 - y1);  // Afficher le rectangle de sélection 
  }
  }
  
  // Fonction pour désélectionner la zone sélectionnée
void deselect() {
  x1 = y1 = x2 = y2 = 0;  // Réinitialiser les coordonnées de la sélection
  isDragging = false;  // Désactiver le drag
  NomDuboutonActif = "";  // Désélectionner l'outil actif
}

                   //*****************************************************************************************************************************************
                    
// Sauvegarder l'état de l'image dans la pile Undo
void sauvegardeUndo() {
  undoMemoire.add(img.copy());  // Sauvegarder l'image actuelle dans l'historique "undo"
  redoMemoire.clear();  // Vider la pile "redo" lorsqu'une nouvelle modification est effectuée
}


                    //*****************************************************************************************************************************************
                    
// Fonction pour annuler la dernière modification (Undo)
void undo() {
  if (undoMemoire.size() > 0) {
    PImage lastState = undoMemoire.remove(undoMemoire.size() - 1);  // Récupérer l'état précédent
    redoMemoire.add(img.copy());  // Sauvegarder l'état actuel pour un possible Redo
    img = lastState;  // Restaurer l'état précédent de l'image
  }
}

                //*****************************************************************************************************************************************
                    
// Fonction pour refaire la dernière modification annulée (Redo)
void redo() {
  if (redoMemoire.size() > 0) {
    PImage nextState = redoMemoire.remove(redoMemoire.size() - 1);  // Récupérer l'état suivant
    undoMemoire.add(img.copy());  // Sauvegarder l'état actuel pour un possible Undo
    img = nextState;  // Restaurer l'état suivant de l'image
  }
}
                 //*****************************************************************************************************************************************
                    
// Fonction pour zoomer
void zoomPlus() {
  zoomFactor = constrain(zoomFactor + 0.1, 0.5, 3.0);  // Limite entre 0.5x et 3.0x
}

                 //*****************************************************************************************************************************************
                    
// Fonction pour dézoomer
void zoomMoins() {
  zoomFactor = constrain(zoomFactor - 0.1, 0.5, 3.0);  // Limite entre 0.5x et 3.0x
}

// la fonction de sauvegarde d'image en jpg
void enregistrerJpg(){
   // Créer un PImage pour l'image sans la barre d'outils
  PImage imgSansBarreDoutil = createImage(int(img.width),int( height), RGB);  // Créer une nouvelle image sans la barre d'outils

imgSansBarreDoutil=img.copy();  // Copier l'image modifiée 

  // Sauvegardr l'image
   imgSansBarreDoutil.save("image.jpg");
   println("image enrégistrée");
}
