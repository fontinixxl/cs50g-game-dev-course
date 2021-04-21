using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class DespawnOnHeight : MonoBehaviour {

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		if (transform.position.y < -5) {
			// destroy whisperSource before loading GameOver scene to avoid overlaping
			Destroy (GameObject.FindWithTag("WhisperSource"));
			GrabPickups.level = 1;
			SceneManager.LoadScene("GameOver");
		}

	}
}
