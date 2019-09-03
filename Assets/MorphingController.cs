using System.Runtime.InteropServices;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class MorphingController : MonoBehaviour
{
    struct CharaData
    {
        public Vector2 vertex;
        public Vector2 uv;
    }

    [SerializeField] GameObject originTxt;
    [SerializeField] GameObject targetTxt;

    [SerializeField] Material origin;
    [SerializeField] Material target;

    [SerializeField, Range(0.01f, 1f)] float speed = 0.25f;
    [SerializeField, Range(0f, 1f)] float easing = 0.1f;

    private ComputeBuffer buffer;
    private int num = 86;

    #region Shader property IDs
    private struct ShaderIDs
    {
        public static readonly int Speed = Shader.PropertyToID("_Speed");
        public static readonly int Easing = Shader.PropertyToID("_Easing");
    }
    #endregion

    void Awake()
    {
        originTxt.SetActive(false);
        targetTxt.SetActive(true);
    }

    void Start()
    {
        buffer = new ComputeBuffer(num, Marshal.SizeOf(typeof(CharaData)), ComputeBufferType.Default);
        Graphics.SetRandomWriteTarget(1, buffer, true);
        target.SetBuffer("_TargetChara", buffer);
        StartCoroutine(Test());
    }

    private void Update()
    {
        origin.SetFloat(ShaderIDs.Speed, speed);
        origin.SetFloat(ShaderIDs.Easing, easing);
    }

    void OnDestroy()
    {
        if (buffer != null) buffer.Release();
    }

    IEnumerator Test()
    {
        yield return new WaitForSeconds(0.05f); // targetの情報を読む時間が必要
        Graphics.ClearRandomWriteTargets();
        origin.SetBuffer("_TargetChara", buffer);
        originTxt.SetActive(true);
        targetTxt.SetActive(false);
    }


}
