using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SwappableRenderTexture
{
    /// <summary>
    /// Buffer containing both render textures
    /// </summary>
    private RenderTexture[] _buffers;
    private int _readID = 0;
    private int _writeID = 1;

    #region Properties
    /// <summary>
    /// Accessor to the Read render texture
    /// </summary>
    public RenderTexture Read
    {
        get
        {
            return _buffers[_readID];
        }
    }

    /// <summary>
    /// Accessor to the Write render texture
    /// </summary>
    public RenderTexture Write
    {
        get
        {
            return _buffers[_writeID];
        }
    } 

    public TextureWrapMode wrapModeU
    {
        set
        {
            _buffers[0].wrapModeU = value;
            _buffers[1].wrapModeU = value;
        }
        get
        {
            return _buffers[0].wrapModeU;
        }
    }

    public TextureWrapMode wrapModeV
    {
        set
        {
            _buffers[0].wrapModeV = value;
            _buffers[1].wrapModeV = value;
        }
        get
        {
            return _buffers[0].wrapModeV;
        }
    }

    #endregion

    #region Constructor
    /// <summary>
    /// Create a double buffered renderTexture
    /// </summary>
    public SwappableRenderTexture(int width, int height, RenderTextureFormat format, TextureWrapMode wrapMode, FilterMode filterMode)
    {
        _buffers = new RenderTexture[2];
        _buffers[0] = CreateRenderTexture(width, height, format, wrapMode, filterMode);
        _buffers[1] = CreateRenderTexture(width, height, format, wrapMode, filterMode);
    }
    #endregion

    #region Functions
    /// <summary>
    /// Creates a writable render texture 
    /// </summary>
    public static RenderTexture CreateRenderTexture(int width, int height, RenderTextureFormat format, TextureWrapMode wrapMode, FilterMode filterMode)
    {
        RenderTexture renderTexture = new RenderTexture(width, height, 0, format, RenderTextureReadWrite.Linear);
        renderTexture.enableRandomWrite = true;
        renderTexture.wrapMode = wrapMode;
        renderTexture.filterMode = filterMode;
        renderTexture.Create();
        return renderTexture;
    }

    /// <summary>
    /// Release the allocated buffer
    /// </summary>
    public void Release()
    {
        _buffers[0].Release();
        _buffers[1].Release();
        _buffers = null;
    } 

    public void Swap()
    {
        (_writeID, _readID) = (_readID, _writeID);
    }
    #endregion
}
