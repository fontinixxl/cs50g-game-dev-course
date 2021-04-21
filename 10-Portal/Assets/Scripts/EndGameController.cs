using System.Collections;
using UnityEngine.UI;
using UnityEngine;
using UnityEngine.SceneManagement;

public class EndGameController : MonoBehaviour
{

    public Text textComponent;

    public string endGameText = "";

    // Start is called before the first frame update
    void Start()
    {
        // disable the text component just when we start the game.
        textComponent.enabled = false;
    }

    // Update is called once per frame
    void Update()
    {

    }

    private void OnTriggerEnter(Collider other)
    {
        // Once the endGameCollider is triggerd, we enable the EndGame Text
        textComponent.text = endGameText;
        textComponent.enabled = true;

        Invoke("restartScene", 2f);
    }

    private void restartScene() {
        // start over from the begining when we leave the collider zone
        SceneManager.LoadScene("main");
    }

}
