package br.gsj.besouro.utils

import java.util.Arrays

object Functions {
  def softmax(values: Array[Double]): Array[Double] = {

    val e = values.map(f => Math.exp(f))
    val e_sum = e.sum
    
    var result = new Array[Double](values.size)
    
    for(x <- 0 to result.size -1){
      result(x) = e(x) / e_sum
    }

    return result;
  }

  def main(args: Array[String]): Unit = {
     val x = Array[Double](10, 10, 10, 10)
     
     val r = softmax(x)
     
     r.foreach(println)
  }

}