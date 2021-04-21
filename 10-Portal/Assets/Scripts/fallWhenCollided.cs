using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class fallWhenCollided : MonoBehaviour
{

    public GameObject parentCube;

    public float timeToFall  = 1.5f;

    private Transform cube;

    private Rigidbody rb;

    // Start is called before the first frame update
    void Start()
    {
        rb = parentCube.GetComponent<Rigidbody>();
        cube = parentCube.GetComponent<Transform>();
    }

    // Update is called once per frame
    void Update()
    {
        if (cubeHasFallenFarDown()) {
             Destroy(parentCube);
        }
    }
    private void OnTriggerEnter(Collider other)
    {
        Invoke("makeCubeFall", timeToFall);
    }

    private void makeCubeFall() {
        rb.isKinematic = false;
    }
    
    private bool cubeHasFallenFarDown()
    {
        return cube.position.y < -10;
    }

}
