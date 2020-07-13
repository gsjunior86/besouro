package br.gsj.besouro

import br.gsj.server.besouro.BesouroServer

object BesouroStarter {
  
  def main(args: Array[String]): Unit = {
    
    val server = new BesouroServer(2222)
    server.run()
    
  }
  
}