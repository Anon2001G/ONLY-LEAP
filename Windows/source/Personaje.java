import processing.core.PApplet;
import processing.core.PVector;
import processing.core.PImage;
import java.util.ArrayList;

// CLASE DEL PERSONAJE
class Personaje {

  // VARIABLES GLOBALES
  PApplet applet;
  PImage personajeImg;
  
  PVector acceleration;
  PVector velocity;
  PVector position;
  float mass;
  float widthEllipse, heightEllipse;
  
  PVector collisionPos;
  PVector collisionPos2;
  
  boolean jumpMax = true;
  boolean jumping = false;
  
  float horizontal = 0;
  
  // CONSTRUCTOR DE LA CLASE
  public Personaje(float mass, PVector position, PVector velocity, PVector acceleration, float widthEllipse, float heightEllipse, PApplet applet, PImage personajeImg){
    this.applet = applet;
    this.personajeImg = personajeImg;
    
    this.acceleration = acceleration;
    this.velocity = velocity;
    this.position = position;
    this.mass = mass;
    this.widthEllipse = widthEllipse;
    this.heightEllipse = heightEllipse;
    
    // Se ponen los vectores de posicion de los colliders del personaje ( uno abajo a la izquierda / uno abajo a la derecha )
    collisionPos = new PVector(position.x - 34, position.y + 53);
    collisionPos2 = new PVector(position.x + 34, position.y + 53);
  }
  
  // MÉTODO PARA DIBUJAR AL PERONAJE
  public void dibujarPersonaje(ArrayList<Plataforma> plataformas, float speedLimit, float speed, float limitLeft, float limitRight) {
    
    // Si supera los límites de la derecha o izquierda, se resetea su posición para que no pueda pasar por los lados de la pantalla
    position.x = position.x > limitRight ? limitRight : position.x;
    position.x = position.x < limitLeft ? limitLeft : position.x;
    
    // Si la posición en el eje Y es el límite de arriba de la pantalla, las plataformas aumentan su velocidad y su posición se resetea al límite ( desacelera más rápidamente durante este tiempo )
    if (position.y < 0){
      for (Plataforma plataforma : plataformas){
        plataforma.Up(speedLimit);
      }
      
      position = new PVector(position.x, 0);
      velocity = velocity.sub(0, velocity.y * (0.02f + 0.05f * speed));
    }
    
    // Se dibuja la imagen en esa posición
    applet.image(personajeImg, position.x - widthEllipse/2, position.y - heightEllipse/2, widthEllipse, heightEllipse);
    
    // Se resetean las posiciones de los colliders junto al personaje ( en su sitio )
    collisionPos = new PVector(position.x - 34, position.y + 53);    
    collisionPos2 = new PVector(position.x + 34, position.y + 53);
  }
  
  // MÉTODO QUE RETORNA EL IMPULSO
  public PVector collisionImpulse(ArrayList<PVector> platformPosition, ArrayList<Float> platformWidth, ArrayList<Float> platformHeight, float cantJumpHiger, float platformMass, float e, int space){
    
    // Lo hace para cada plataforma
    for (int i = 0; i < platformPosition.size(); i++){
      
      // Si presiona el espacio y puede saltar, está saltando
      if (applet.keyCode == space && jumpMax){
        jumping = true;
      }
      
      // Si está saltando
      if (jumping){
        
        // La tecla se está presionando
        applet.keyPressed = true;   
        
        // Si puede hacer el salto más grande
        if (getCoyoteTime(platformPosition.get(i), platformWidth.get(i), 80)){
          
          // No va a poder saltar más hasta que salga de la zona en donde puede hacer el salto más grande
          jumpMax = false;
          
          // Se resetea la velocidad por si es muy alta ( el impulso depende de la velocidad, si es muy alta va a impulsarse muy alto )
          if (velocity.y <= 120 || velocity.y > 155){
            velocity.y = 150;
          }
          jumping = false;
          
          // Retorna la nueva velocidad
          return new PVector(velocity.x, -((getImpulse(new PVector(0, -1), new PVector(0, velocity.y), new PVector(0, 0), mass, platformMass, e) / mass) * cantJumpHiger));
        }
        
        // Se resetea el keyCode ( si no, va a estar saltando cte )
        applet.keyCode = 0;
      }
      
      // Si sale de la zona de salto más grande, se resetea para que pueda saltar otra vez ( cuando llegue otra vez a esta )
      if (!getCoyoteTime(platformPosition.get(i), platformWidth.get(i), 20)){
        jumpMax = true;
      }
      
      // Si los colliders están cerca de la plataforma y no se ha dado al espacio
      boolean firstCollision = (collisionPos.y >= platformPosition.get(i).y && collisionPos.y <= platformPosition.get(i).y + platformHeight.get(i) + 10) && (collisionPos.x >= platformPosition.get(i).x && collisionPos.x <= platformPosition.get(i).x + platformWidth.get(i) - 5);
      boolean secondCollision = (collisionPos2.y >= platformPosition.get(i).y && collisionPos2.y <= platformPosition.get(i).y + platformHeight.get(i) + 10) && (collisionPos2.x >= platformPosition.get(i).x && collisionPos2.x <= platformPosition.get(i).x + platformWidth.get(i) - 5);
      
      if (firstCollision || secondCollision){
        
        // Se resetea la velocidad por si es muy alta ( el impulso depende de la velocidad, si es muy alta va a impulsarse muy alto )
        if (velocity.y <= 120 || velocity.y > 155){
          velocity.y = 150;
        }
        jumping = false;
        
        // Retorna la nueva velocidad
        return new PVector(velocity.x, -(getImpulse(new PVector(0, -1), new PVector(0, velocity.y), new PVector(0, 0), mass, platformMass, e) / mass));
      }
    }
    jumping = false;
    
    // Retorna la velocida ( si no se ha presionado el espacio o si los colliders no están en la zona de colisión )
    return new PVector(velocity.x, velocity.y);
  }
  
  // MÉTODO QUE RETORNA SI LOS COLLIDERS ESTÁN EN LA ZONA DE COLLISIÓN
  public boolean getCoyoteTime(PVector platformPosition, float platformWidth, float limitCoyote){
    
    boolean firstCollision = (collisionPos.y >= platformPosition.y - limitCoyote && collisionPos.y <= platformPosition.y + 40) && (collisionPos.x >= platformPosition.x && collisionPos.x <= platformPosition.x + platformWidth);
    boolean secondCollision = (collisionPos2.y >= platformPosition.y - limitCoyote && collisionPos2.y <= platformPosition.y + 40) && (collisionPos2.x >= platformPosition.x && collisionPos2.x <= platformPosition.x + platformWidth);
    
    if (firstCollision || secondCollision){
      return true;
    }
    return false;
  }
  
  // MÉTODO PARA MOVERSE A LOS LADOS
  public void move(float speed, int right, int left){
    
    // Si presionas la tecla
    if (applet.keyPressed){
      
      // Si la tecla presionada es flecha derecha o izquierda
      if (applet.keyCode == right){      
        velocity = new PVector(speed, velocity.y);
      }else if (applet.keyCode == left){
        velocity = new PVector(-speed, velocity.y);
      }
    }else velocity = new PVector(0, velocity.y);
  }
  
  // MÉTODO QUE RETORNA SI HAS PERDIDO
  public boolean lose(int heightWindow){
    
    // Si la posición en el eje Y está en la posición más baja, has perdido
    if (position.y >= heightWindow - 40) return true;
    return false;
  }
  
  // MÉTODO QUE DEVUELVE LA MAGNITUD DEL IMPULSO
  public float getImpulse(PVector Un, PVector Va0, PVector Vb0, float ma, float mb, float e){
    PVector Vrel0 = PVector.sub(Va0, Vb0);
    
    return (PVector.dot(Un, Vrel0) * (-1-e))/((1/ma) + (1/mb));
    
  }
}
