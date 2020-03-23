using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class SwitchPanels : MonoBehaviour 
{
	public GameObject Menu;
	public GameObject Panel;

	private void Awake()
	{
		var toggle = GetComponent<Toggle> ();
		toggle.onValueChanged.AddListener (OnToggleClick);
	}

	public void OnToggleClick(bool isActive)
	{
		Menu.SetActive (isActive);
		Panel.SetActive (!isActive);
	}

}
