using UnityEngine;

[ExecuteInEditMode]
public class SyncSceneCamera : MonoBehaviour
{
    public Camera m_Camera;
    public bool m_IsEditorTime;

#if UNITY_EDITOR

    void OnRenderObject()
    {
        if (!Application.isPlaying && !m_IsEditorTime)
        {
            return;
        }

        Camera currentCamera = Camera.current;
        if (currentCamera != null && currentCamera.name == "SceneCamera" && m_Camera != null)
        {
            m_Camera.transform.position = currentCamera.transform.position;
            m_Camera.transform.rotation = currentCamera.transform.rotation;
        }
    }
#endif
}
