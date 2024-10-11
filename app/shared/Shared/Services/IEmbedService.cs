// Copyright (c) Microsoft. All rights reserved.

public interface IEmbedService
{
    /// <summary>
    /// Embeds the given pdf blob into the embedding service.
    /// </summary>
    /// <param name="blobStream">The stream from the blob to embed.</param>
    /// <param name="blobName">The name of the blob.</param>
    /// <returns>
    /// An asynchronous operation that yields <c>true</c>
    /// when successfully embedded, otherwise <c>false</c>.
    /// </returns>
    Task<bool> EmbedPDFBlobAsync(
        Stream blobStream,
        string blobName);

    /// <summary>
    /// Embeds the given image blob into the embedding service.
    /// </summary>
    /// <param name="imageStream">The stream from the image blob to embed.</param>
    /// <param name="imageUrl">The URL of the image.</param>
    /// <param name="imageName">The name of the image.</param>
    /// <param name="ct">Optional. A <see cref="CancellationToken"/> to observe while waiting for the task to complete.</param>
    /// <returns>
    /// An asynchronous operation that yields <c>true</c>
    /// when successfully embedded, otherwise <c>false</c>.
    /// </returns>
    Task<bool> EmbedImageBlobAsync(
        Stream imageStream,
        string imageUrl,
        string imageName,
        CancellationToken ct = default);

    /// <summary>
    /// Embeds the given JSON blob into the embedding service.
    ///     /// </summary>
    /// <param name="stream">The stream from the JSON blob to embed.</param>
    /// <param name="url">The URL of the JSON blob.</param>
    /// <param name="ct">Optional. A <see cref="CancellationToken"/> to observe while waiting for the task to complete.</param>
    /// <returns>
    /// An asynchronous operation that yields <c>true</c>
    /// when successfully embedded, otherwise <c>false</c>.
    /// </returns>
    Task<bool> EmbedJSONBlobAsync(
        Stream stream,
        string url, 
        CancellationToken ct = default);

    /// <summary>
    /// Creates a search index with the specified name.
    /// </summary>
    /// <param name="searchIndexName">The name of the search index to create.</param>
    /// <param name="ct">Optional. A <see cref="CancellationToken"/> to observe while waiting for the task to complete.</param>
    /// <returns>
    /// An asynchronous operation.
    /// </returns>
    Task CreateSearchIndexAsync(string searchIndexName, CancellationToken ct = default);

    /// <summary>
    /// Ensures that a search index with the specified name exists.
    /// </summary>
    /// <param name="searchIndexName">The name of the search index to ensure.</param>
    /// <param name="ct">Optional. A <see cref="CancellationToken"/> to observe while waiting for the task to complete.</param>
    /// <returns>
    /// An asynchronous operation.
    /// </returns>
    Task EnsureSearchIndexAsync(string searchIndexName, CancellationToken ct = default);
}
