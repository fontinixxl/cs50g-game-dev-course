using UnityEngine;
using UnityEngine.UI;
using System.Collections;

[RequireComponent(typeof(Text))]
public class levelText : MonoBehaviour {
	
	private Text text;
    private int level;

    // Use this for initialization

    void Start () {
		text = GetComponent<Text>();
	}
	
	// Update is called once per frame
	void Update () {
		level = GrabPickups.level;
		text.text = "Level: " + level;
	}
}
