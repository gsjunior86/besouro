package br.gsj.besouro.pojo

class Environment {

  var current_state: State = null
  var result_state: State = null

  def compute_reward(): Int = {
    if ((result_state != null && current_state != null)
        && result_state.player2_life < current_state.player2_life) {
      println("Reward: " + (result_state.player2_life - current_state.player2_life))
      return result_state.player2_life - current_state.player2_life
    }
    return 0
  }

  def set_current_state(state: State) = {
    current_state = state
  }

  def set_result_state(state: State) = {
    result_state = state
  }

}