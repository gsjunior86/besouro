package br.gsj.server.besouro

import java.net.ServerSocket
import java.io.PrintWriter
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.File
import java.io.BufferedWriter
import java.io.FileWriter
import br.gsj.besouro.rl.Training
import br.gsj.besouro.pojo.Environment
import br.gsj.besouro.pojo.State

class BesouroServer(port: Int) {

  // val fileData = new File("src/main/resources/training.data")
  // val fw = new FileWriter(fileData,true)

    def run() = {
    while (true) {
      val serverSocket = new ServerSocket(port);
      println("Besouro Server Started ...")
      val clientSocket = serverSocket.accept();

      serverSocket.close()
      val out = new PrintWriter(clientSocket.getOutputStream())
      val in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()))

      val environment = new Environment
      var line = "";
      try {
        while (line != null) {
          line = in.readLine()

          create_state(line, environment)

          environment.compute_reward()

          out.println(Training.sort_command() + 1)
          out.flush()

        }
      } catch {
        case t: Throwable => println("Client Disconected ...")
      }

    }
  }

  def create_state(s: String, env: Environment): State = {

    val array_info = s.split(",")

    val state = new State(
      array_info(2).toInt,
      if (array_info(3).equals("-")) -1 else array_info(3).toInt,
      array_info(4).toInt,
      if (array_info(5).equals("-")) -1 else array_info(5).toInt,
      array_info(6).toInt,
      array_info(7).toInt,
      array_info(8).toInt,
      array_info(9).toInt,
      array_info(10).toInt,
      array_info(11).toInt)

    if (array_info(1).equals("a")) {
      env.set_current_state(state)

    } else if (array_info(1).equals("b")) {
      env.set_result_state(state)
    }

    return state
  }

}