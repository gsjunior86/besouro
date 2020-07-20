package br.gsj.besouro.supervised

import org.deeplearning4j.nn.conf.NeuralNetConfiguration
import org.deeplearning4j.nn.weights.WeightInit
import org.nd4j.linalg.learning.config.Nesterovs
import org.nd4j.linalg.learning.config.AdaGrad
import org.nd4j.linalg.activations.Activation
import org.deeplearning4j.nn.conf.layers.DenseLayer
import org.deeplearning4j.nn.conf.layers.OutputLayer
import org.deeplearning4j.nn.api.OptimizationAlgorithm
import org.nd4j.linalg.lossfunctions.LossFunctions

//import org.deeplearning4j.nn.conf.layers.


object Training {
  
  def main(args: Array[String]): Unit = {
    val nEpochs = 30
    val seed = 12345
    val learningRate = 0.005
    
    val configuration = new NeuralNetConfiguration.Builder()
    .seed(seed)
    .weightInit(WeightInit.XAVIER)
    .updater(new AdaGrad(0.5,learningRate))
    .activation(Activation.SIGMOID)
    .optimizationAlgo(OptimizationAlgorithm.STOCHASTIC_GRADIENT_DESCENT)
    .list()
    .layer(0, new DenseLayer.Builder()
            .nIn(256).nOut(160)
            .weightInit(WeightInit.XAVIER)
            .activation(Activation.SIGMOID) 
            .build())
     .layer(1, new DenseLayer.Builder()
            .nIn(160).nOut(64)
            .weightInit(WeightInit.XAVIER)
            .activation(Activation.SIGMOID) 
            .build())
      .layer(2, new DenseLayer.Builder()
            .nIn(64).nOut(32)
            .weightInit(WeightInit.XAVIER)
            .activation(Activation.SIGMOID) 
            .build())
       .layer(3, new OutputLayer.Builder()
            .nIn(32).nOut(10)
            .weightInit(WeightInit.XAVIER)
            .activation(Activation.SIGMOID)
            .lossFunction(LossFunctions.LossFunction.RECONSTRUCTION_CROSSENTROPY)
            .build())
    //.layer(new Input)
    .build()
    
    
  }
  
}