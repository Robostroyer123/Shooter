using JetBrains.Annotations;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ApplicationSettings : MonoBehaviour
{
    public void Quit()
    {
        print("Quit");
        Application.Quit();
    }
    public void LoadScene(int index = 0)
    {
        print("Load Scene");
        UnityEngine.SceneManagement.SceneManager.LoadScene(index);
    }
}
