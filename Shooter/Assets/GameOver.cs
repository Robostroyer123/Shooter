using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GameOver : MonoBehaviour
{
    public Transform gameOverCanvas;
    public void Start()
    {
        if(gameOverCanvas != null) gameOverCanvas.gameObject.SetActive(false);
        Time.timeScale = 1.0f;
    }
    public void Trigger()
    {
        if (gameOverCanvas != null) gameOverCanvas.gameObject.SetActive(true);
        Time.timeScale = 0;
    }
}
