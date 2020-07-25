package br.gsj.besouro.utils

import java.io.File
import java.io.FileReader
import java.io.BufferedReader
import java.io.FileWriter

object DSConverter {
  
  def main(args: Array[String]): Unit = {
    val inputFile = new File("src/main/resources/training.data")
    val outputFile = new File("src/main/resources/training_new.data")
    val fw = new FileWriter(outputFile)
    val br = new BufferedReader(new FileReader(inputFile))
    var s = br.readLine()
    while( s != null){
      println(s)
      s = br.readLine()
    }
    
  }
  
}