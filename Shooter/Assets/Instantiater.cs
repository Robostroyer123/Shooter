using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Instantiater : MonoBehaviour
{
    public void InstantiateObject(GameObject @object)
    {
        Instantiate(@object, transform.position, transform.rotation);
    }
}
