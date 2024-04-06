using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Collider))]
public class PortalableObject : MonoBehaviour
{
    private GameObject cloneObject;

    private int inPortalCount = 0;
    
    private Portal inPortal;
    private Portal outPortal;

    private new Rigidbody rigidbody;
    protected new Collider collider;

    private static readonly Quaternion halfTurn = Quaternion.Euler(0.0f, 180.0f, 0.0f);

    MeshRenderer m_Renderer;
    MeshFilter m_Filter;

    public int InPortalCount { get { return inPortalCount; } }

    protected virtual void Start()
    {
        if(!TryGetComponent(out m_Renderer))
        {
            m_Renderer = GetComponentInChildren<MeshRenderer>();
        }
        if (!TryGetComponent(out m_Filter))
        {
            m_Filter = GetComponentInChildren<MeshFilter>();
        }
        cloneObject = new GameObject();
        cloneObject.SetActive(false);
        var meshFilter = cloneObject.AddComponent<MeshFilter>();
        var meshRenderer = cloneObject.AddComponent<MeshRenderer>();

        meshFilter.mesh = m_Filter.mesh;
        meshRenderer.materials = m_Renderer.materials;
        cloneObject.transform.localScale = transform.localScale;

        TryGetComponent(out rigidbody);
        TryGetComponent(out collider);
    }

    private void LateUpdate()
    {
        if(inPortal == null || outPortal == null)
        {
            return;
        }

        if(cloneObject.activeSelf && inPortal.IsPlaced && outPortal.IsPlaced)
        {
            var inTransform = inPortal.transform;
            var outTransform = outPortal.transform;

            // Update position of clone.
            Vector3 relativePos = inTransform.InverseTransformPoint(transform.position);
            relativePos = halfTurn * relativePos;
            cloneObject.transform.position = outTransform.TransformPoint(relativePos);

            // Update rotation of clone.
            Quaternion relativeRot = Quaternion.Inverse(inTransform.rotation) * transform.rotation;
            relativeRot = halfTurn * relativeRot;
            cloneObject.transform.rotation = outTransform.rotation * relativeRot;
        }
        else
        {
            cloneObject.transform.position = new Vector3(-1000.0f, 1000.0f, -1000.0f);
        }
    }

    public void SetIsInPortal(Portal inPortal, Portal outPortal, Collider wallCollider)
    {
        this.inPortal = inPortal;
        this.outPortal = outPortal;

        Physics.IgnoreCollision(collider, wallCollider);

        cloneObject.SetActive(false);

        ++inPortalCount;
    }

    public void ExitPortal(Collider wallCollider)
    {
        Physics.IgnoreCollision(collider, wallCollider, false);
        --inPortalCount;

        if (inPortalCount == 0)
        {
            cloneObject.SetActive(false);
        }
    }

    public virtual void Warp()
    {
        var inTransform = inPortal.transform;
        var outTransform = outPortal.transform;

        // Update position of object.
        Vector3 relativePos = inTransform.InverseTransformPoint(transform.position);
        relativePos = halfTurn * relativePos;
        transform.position = outTransform.TransformPoint(relativePos);

        // Update rotation of object.
        Quaternion relativeRot = Quaternion.Inverse(inTransform.rotation) * transform.rotation;
        relativeRot = halfTurn * relativeRot;
        transform.rotation = outTransform.rotation * relativeRot;
        if (TryGetComponent(out StarterAssets.FirstPersonController first))
        {
            transform.localEulerAngles = Vector3.up * transform.localEulerAngles.y;
            //first.InvertVerticalVelocity();
        }

        if (rigidbody != null)
        {
            // Update velocity of rigidbody.
            Vector3 relativeVel = inTransform.InverseTransformDirection(rigidbody.velocity);
            relativeVel = halfTurn * relativeVel;
            rigidbody.velocity = outTransform.TransformDirection(relativeVel);
        }
        //Physics.SyncTransforms();

        // Swap portal references.
        var tmp = inPortal;
        inPortal = outPortal;
        outPortal = tmp;
    }
}
