// JUEGO CREADO POR GABRIEL CAÑIZARES VALDERAS
// 1º CURSO DE DISEÑO Y DESARROLLO DE VIDEOJUEGOS

// CONSTANTES
import java.util.ArrayList;
import java.io.IOException;

final int widthWindow = 750;
final int heightWindow = 890;

final float CharacterMass = 2;
final float CharacterWidth = 80;
final float CharacterHeight = 110;

final float PlataformMass = 1;
final float coeficienteElastico = 1.9;

final float deltaTime = 0.1;
final float gravity = 60;
final int heightPlataformas = 25;
final int SPACE = 32;

// VARIABLES GLOBALES

boolean lose = false;
boolean menu = true;

int puntuacion = 0;
int nuevasPuntuaciones;
int maxPuntuaciones;

float speed = 1.8f;
float speedMove = 80;

// porcentaje de mayor salto
float jumpHigher = 40;

float speedTimer = 0;
float speedText = 0.5f;
float brightness = 35;
float timer = 0;
float alpha = 0;

ArrayList<Plataforma> plataforms = new ArrayList<>();
ArrayList<PVector> plataformPositions = new ArrayList<>();
ArrayList<Float> plataformWidths = new ArrayList<>();
ArrayList<Float> plataformHeights = new ArrayList<>();
int platNumber = 0;
float widthPlat2, widthPlat3;

// VECTORES DE DEL PERSONAJE
PVector position;
PVector velocity;
PVector acceleration;

// CLASES
PImage botonImg;
PImage boton2Img;
PImage fondoImg;
PImage fondo2Img;
PImage personajeImg;

PVector force;

Personaje personaje;

Plataforma plat_1;
Plataforma plat_2;
Plataforma plat_3;

// MAIN BEGIN
void setup(){
  
  // CONFIGURACIÓN DE LA VENTANA DE INICIO
  size(750, 880);
  background(10);
  
  surface.setTitle("ONLY LEAP");
  surface.setResizable(false);
  surface.setLocation(580, 50);
  
  // CARGAR TODAS LAS IMAGENES
  botonImg = loadImage("Boton.png");
  boton2Img = loadImage("Boton2.png");
  fondoImg = loadImage("Fondo1.png");
  fondo2Img = loadImage("Fondo2.png");
  personajeImg = loadImage("Personaje.png");

  // PRIMERAS CONFIGURACIONES
  position = new PVector(375, 540);
  velocity = new PVector(0, 0);
  acceleration = new PVector(0, 0);
  force = new PVector(0, 0);
  
  // MOSTRAR LA MÁXIMA PUNTUACIÓN
  cargarPuntuacion();  
  
  // CREAR EL OBJETO DE LA CLASE PERSONAJE ( donde van a estar todos los métodos del personaje )
  personaje = new Personaje(CharacterMass, position, velocity, acceleration, CharacterWidth, CharacterHeight, this, personajeImg);
  
}

// MAIN LOOP
void draw(){
  
  // Primero se carga el menú. Después el juego. Finalmente el end.
  if (!menu){
    if (!lose) game();
    else end();
  }else menu();
}

// CARGAR EL MENU
void menu(){
  
  // Se carga el fondo
  image(fondoImg, 0, 0, 750, 950);
  
  // Se cargan los textos, junto a la underline
  textFont(createFont("20thfaux.ttf", 100));
  showText(50, "Tu máxima es: " + maxPuntuaciones, new PVector(200, 750), 0, 0, 0, 255);
  showText(140, "ONLY LEAP", new PVector(45, 320), 0, 0, 0, 255);
  showText(140, "ONLY LEAP", new PVector(60, 330), 0, 0, 0, 31);
  
  stroke(0);
  strokeWeight(15);
  line(60, 360, 700, 360);
  
  // Se carga el botón con su configuración ( si se pulsa cerca se quita el menu y se configura el mapa inicial )
  image(botonImg, 160, 400);
  
  if((mouseX >= 190 && mouseX <= 550) && (mouseY >= 430 && mouseY <= 655) && mousePressed){
    menu = false;
    setMap();
  }
}

// CARGAR EL JUEGO
void game(){
  
  // Si pasa de cierta posicion en el eje Y, el método retorna true
  lose = personaje.lose(heightWindow);
  
  // Si no ha perdido, se carga el fondo
  if (!lose) image(fondo2Img, 0, 0, 750, 1500);
  
  // ANIMACIÓN DEL TEXTO DE PUNTAJE ( se configura un timer y con una función cuadrática matemática se hace la animación. se resetea si llega a menor que 0 ) 
  timer += deltaTime * speedText;
  timer = alpha <= 80 ? deltaTime : timer;
  alpha = (float) (-Math.pow(timer, 2) + 4 * timer + 5) * brightness;
    
  if (!lose) showText(80, "Puntuación: " + puntuacion, new PVector(20, 80), 100, 190, 100, alpha);
  
  // RESETEO DEL COLOR
  fill(255);
  
  // CALCULOS DE FÍSICAS
  
  // Se calcula la fuerza del peso ( el speed es para que con el tiempo tenga más peso, y darle más frenesí )
  force = new PVector(0, personaje.mass * (gravity + speed * 2));
  
  // Se calcula la aceleración con la masa
  personaje.acceleration = PVector.mult(force, 1/personaje.mass);
  
  // Se calcula la velocidad con el método de integración numérica de Euler simpléctico
  personaje.velocity = PVector.add(personaje.velocity, PVector.mult(personaje.acceleration, deltaTime));
  
  // Se le añade a la velocidad el impulso ( tiene que cambiar la velocidad en el instante en el que choque )
  personaje.velocity = personaje.collisionImpulse(plataformPositions,  plataformWidths, plataformHeights, 1 + jumpHigher/100, PlataformMass, coeficienteElastico, SPACE);
  
  // Se calcula la posición con el método de integración numérica de Euler simpléctico 
  personaje.position = PVector.add(personaje.position, PVector.mult(personaje.velocity, deltaTime));
  
  // Se le cambia la posición en el eje X dependiendo de si pulsa RIGHT o LEFT
  personaje.move(speedMove + speed, RIGHT, LEFT);
  
  // DIBUJADO DEL MAPA Y PUNTUACIÓN
  
  // Se configura un timer para que con el tiempo las plataformas aceleren
  if (speedTimer >= 8){
    speed += 0.35f;
    speedTimer = 0;
  }else{
    speedTimer += deltaTime;
  }
    
  strokeWeight(5);
  stroke(150, 30, 30);
  
  // Si la plataforma se resetea al punto más alto, se adquiere un punto.
  // Además, se dibujan las plataformas con su velocidad.  
  puntuacion += plat_1.reset(heightWindow, random(0, widthWindow - plataformWidths.get(0)), random(60, 300), plataformWidths, 0); 
  plat_1.dibujarPlataforma(speed);
  
  puntuacion += plat_2.reset(heightWindow, random(0, widthWindow - plataformWidths.get(1)), random(60, 300), plataformWidths, 1); 
  plat_2.dibujarPlataforma(speed);
  
  puntuacion += plat_3.reset(heightWindow, random(0, widthWindow - plataformWidths.get(2)), random(60, 300), plataformWidths, 2);
  plat_3.dibujarPlataforma(speed);
  
  // DIBUJADO DEL PERSONAJE
  
  strokeWeight(8);
  stroke(0, 0, 0);
  
  // Se dibuja al personaje
  personaje.dibujarPersonaje(plataforms, 4, speed, 40, width - 40);
  
  // Si pierde se resetea el fondo y se guarda/carga la puntuación  
  if (lose){
    background(10);
    
    cargarPuntuacion();
  }
}

// CARGAR EL END
void end(){
  
  // MOSTRAR EL TEXTO
  showText(30, "Tu máxima es: " + maxPuntuaciones, new PVector(65, 70), 255, 255, 255, 150);
  showText(110, "HAS PERDIDO", new PVector(60, 340), 100, 75, 0, 170);
  showText(70, "Tu puntuación es: " + puntuacion, new PVector(85, 450), 150, 145, 70, 170);
  
  // MOSTRAR LA IMAGEN DEL BOTON DE "RETURN"
  image(boton2Img, 160, 500);
  
  // Si le das al botón se resetea el juego
  if((mouseX >= 190 && mouseX <= 550) && (mouseY >= 530 && mouseY <= 755) && mousePressed){
    reset();
  }   
}

// SE RESETEAN LAS VARIABLES GLOBALES Y EMPIEZA DE NUEVO
void reset(){
  
  // Poner las variables de como al inicio
  puntuacion = 0;
  
  speed = 1.8f;
  jumpHigher = 40;
  speedTimer = 0;
  speedText = 0.5f;
  brightness = 35;
  timer = 0;  
  alpha = 0;  
  
  plataforms = new ArrayList<>();
  plataformPositions = new ArrayList<>();
  plataformWidths = new ArrayList<>();
  plataformHeights = new ArrayList<>();
  platNumber = 0;
  
  lose = false;
  menu = false;
  
  // Se hacen las configuraciones del setup()
  position = new PVector(375, 620);
  velocity = new PVector(0, 0);
  acceleration = new PVector(0, 0);
  force = new PVector(0, 0);
  
  personaje = new Personaje(CharacterMass, position, velocity, acceleration, CharacterWidth, CharacterHeight, this, personajeImg);
  
  setMap();
  
}

// INICIALIZACIÓN DEL MAPA
void setMap(){
  
  // Se crean los objetos de la clase Plataforma. Se dibujan en la pantalla los objetos en posiciones random del eje X ( el eje Y se define de forma arbitraria )
  // Se ponen los objetos en un ArrayList y se aumenta el número de objetos
  plat_1 = new Plataforma(PlataformMass, new PVector(190, 720), new PVector(0, 0), 350, heightPlataformas, this);
  plataforms.add(plat_1);
  platNumber++;
  
  widthPlat2 = random(60, 300);
  plat_2 = new Plataforma(PlataformMass, new PVector(random(0, widthWindow - widthPlat2), 490), new PVector(0, 0), widthPlat2, heightPlataformas, this);
  plataforms.add(plat_2);
  platNumber++;
  
  widthPlat3 = random(60, 300);
  plat_3 = new Plataforma(PlataformMass, new PVector(random(0, widthWindow - widthPlat2), 220), new PVector(0, 0), widthPlat3, heightPlataformas, this);
  plataforms.add(plat_3);
  platNumber++;
  
  // Se cogen las posiciones, la anchura y altura de cada plataforma y se pone en sus ArrayList
  for (int i = 0; i < platNumber; i++){
    plataformPositions.add(i, plataforms.get(i).position);
    plataformWidths.add(i, plataforms.get(i).widthPlat);
    plataformHeights.add(i, plataforms.get(i).heightPlat);
  }
}

// MÉTODO PARA CARGAR Y GUARDAR LA PUNTUACIÓN 
void cargarPuntuacion(){
  
  // Se coge el valor entero del fichero
  nuevasPuntuaciones = Integer.parseInt(loadStrings("puntuacion.txt")[0]);
  
  // Si la puntuación es mayor que la anterior, se guarda en el fichero de texto
  if (nuevasPuntuaciones < puntuacion) filePrint();
  
  // Si la puntuación es menor que la anterior, la máxima es la anterior
  maxPuntuaciones = nuevasPuntuaciones > puntuacion ? nuevasPuntuaciones : puntuacion;
}

// MÉTODO PARA GUARDAR LA PUNTUACIÓN
void filePrint(){
  try{
    OutputStream output = createOutput("puntuacion.txt");    
    saveBytes(output, String.valueOf(puntuacion).getBytes());
    output.close();
  }catch(IOException excp){
    System.out.println(excp);
  }
}

// MÉTODO PARA MOSTRAR TEXTO
void showText(float size, String str, PVector textPosition, float r, float g, float b, float alpha){
  textSize(size);
  fill(r, g, b, alpha);  
  text(str, textPosition.x, textPosition.y);
  
}
