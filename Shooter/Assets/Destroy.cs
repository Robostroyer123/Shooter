using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Destroy : MonoBehaviour
{
    public void DestroyWithDelay(float delay = 0)
    {
        Destroy(gameObject, delay);
    } 
}
