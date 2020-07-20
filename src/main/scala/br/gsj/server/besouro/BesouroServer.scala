package br.gsj.server.besouro

import java.net.ServerSocket
import java.io.PrintWriter
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.File
import java.io.BufferedWriter
import java.io.FileWriter

class BesouroServer(port: Int) {
  
  val fileData = new File("src/main/resources/training.data")
  val fw = new FileWriter(fileData)
  
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
          var z = false
          var cont = 0
          val arr = line.split("\\|")(1).split(",")
          for (x <- arr){
            if(x.toInt == 0)
              cont = cont + 1
          }
          
          if(cont == arr.length)
            z = true
         
          //println(cont)
          if(!z){
            fw.write(line.trim() + "\n")
            fw.flush()
            println("echo: " + line.trim())
          }
    }
  }
  
  
  
  
  
}