using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour {

	// Use this for initialization
	void Start () {
        Debug.LogWarning("hello");
        string content="";
        SkinnedMeshRenderer[] smrs = this.GetComponentsInChildren<SkinnedMeshRenderer>();
        for(int i=0;i<smrs.Length;i++)
        {
            SkinnedMeshRenderer smr = smrs[i];
            content += string.Format("{0:}\n",smr.name);
            for(int j=0;j<smr.sharedMesh.blendShapeCount;j++)
            {
                content+= string.Format("    {0}\n", smr.sharedMesh.GetBlendShapeName(j));
            }
        }
        Debug.LogWarning(content);
    }
	
	
}
