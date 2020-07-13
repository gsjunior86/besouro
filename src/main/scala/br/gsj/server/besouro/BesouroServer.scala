package br.gsj.server.besouro

import java.net.ServerSocket
import java.io.PrintWriter
import java.io.BufferedReader
import java.io.InputStreamReader

class BesouroServer(port: Int) {
  
  val serverSocket = new ServerSocket(port);
  println("Besouro Server Started ...")
  
  def run() = {
    val clientSocket = serverSocket.accept();
    
    serverSocket.close()
    val out = new PrintWriter(clientSocket.getOutputStream(),true)
    val in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()))
    
    
    
    var line = "";
        while (line  != null){
          line = in.readLine()
          println("echo: " + line)
        	//out.println("resp: " + line);
    }
  }
  
  
  
  
  
}