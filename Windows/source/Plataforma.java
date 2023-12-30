import processing.core.PApplet;
import processing.core.PVector;
import java.util.ArrayList;

// CLASE DE LAS PLATAFORMAS
class Plataforma{
  
  // VARIABLES GLOBALES
  PApplet applet;
  
  float widthPlat, heightPlat;
  float mass;
  PVector velocity;
  PVector position;
  
  // CONSTRUCTOR DE LA CLASE
  public Plataforma(float mass, PVector position, PVector velocity, float widthPlat, float heightPlat, PApplet applet){
    this.applet = applet;
    
    this.position = position;
    this.velocity = velocity;
    
    this.mass = mass;
    this.widthPlat = widthPlat;
    this.heightPlat = heightPlat;
    
    applet.rect(position.x, position.y, widthPlat, heightPlat);
  
  }
  
  // MÉTODO QUE DIBUJA LAS PLATAFORMAS
  public void dibujarPlataforma(float speed){
    
    // Se le añade la velocidad a la posición
    position = position.add(0, speed);
    
    // El rectángulo se dibuja y colorea
    applet.fill(60, 0, 0);
    applet.rect(position.x, position.y, widthPlat, heightPlat);
    applet.fill(255);
  }
  
  // MÉTODO PARA RESETEAR LA POSICIÓN DE LAS PLATAFORMAS
  public int reset(int heightWindow, float random, float randomWidths, ArrayList<Float> widthPlataformas, int i){
    
    // Si la posición en el eje Y es la del punto más bajo
    if (position.y >= heightWindow - heightPlat){
      
      // Su posición en el eje Y se resetea al punto más alto y su posición en el eje X se hace pseudoaleatoria entre dos números
      position = position.set(random, heightPlat);
      
      // Su anchura también se hace pseudoaleatoria
      widthPlat = randomWidths;
      widthPlataformas.set(i, widthPlat);
      
      // Retorna 1 cuando se resetea ( se gana 1 punto )
      return 1;
    }
    
    // Retorna 0 cuando no se resetea ( no se gana punto )
    return 0;
  }
  
  // MÉTODO QUE ACELERA LA PLATAFORMA
  public void Up(float speedLimit){
    
    // Se le otra velocidad a la posición ( se superponen las dos velocidades y acelera ) 
    position = position.add(0, speedLimit);
  }
}
