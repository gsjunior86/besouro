package br.gsj.besouro.supervised

import org.deeplearning4j.nn.multilayer.MultiLayerNetwork
import java.io.File
import org.nd4j.linalg.factory.Nd4j

object MovePredictor {
  
  
  def main(args: Array[String]): Unit = {
    
    val net = MultiLayerNetwork.load(new File("src/main/resources/model.data"), true)
    
    val a = Array(Array[Integer](1,0,0,0,0,0,1,0))
    val input = Nd4j.createFromArray(a)
    val p = net.output(input)
    
    println(p)
    
  }
  
}