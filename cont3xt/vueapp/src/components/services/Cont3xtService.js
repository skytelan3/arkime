import Observable from '@/utils/Observable';

export default {
  /**
   * Decodes an array of 8-bit unsigned integers into text
   * @param {Array} arr - Uint8Array
   * @returns {String} - The text represented by the Uint8Array array
   */
  decoder (arr) {
    const dec = new TextDecoder('utf-8');
    return dec.decode(arr);
  },

  /**
   * Parses JSON and sends the chunk to the subscriber.
   * Also sends any errors to the subscriber.
   * Logs JSON parsing errors to the console with the offending JSON.
   * @param {Object} subscriber - The subscriber to send chunks
   * @param {String} chunk - The stringified JSON to parse and send to the subscriber
   */
  sendChunk (subscriber, chunk) {
    // Skip the chunk that is just [
    if (chunk.length < 2) { return; }

    try { // try to parse and send the chunk
      const json = JSON.parse(chunk);
      subscriber.next(json);
    } catch (err) {
      subscriber.error(`ERROR: ${err}`);
      console.log(`Error parsing this chunk:\n${chunk}`);
    }
  },

  /**
   * Fetches integration data from the server given a search term.
   * Watches for a stream of data then reads and parses each chunk.
   * Sends chunks back to the subscriber of the search.
   * @param {String} searchTerm - The query to search the integrations for
   * @returns {Observable} - The observable object to subscribe to updates
   */
  search (searchTerm) {
    return new Observable((subscriber) => {
      searchTerm = searchTerm.trim();

      if (!searchTerm) { // nothing to do
        return subscriber.complete();
      }

      fetch('api/integration/search', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ query: searchTerm })
      }).then((response) => {
        if (!response.ok) { // test for bad response code (only on first chunk)
          throw new Error(response.statusText);
        }
        return response.body;
      }).then((rStream) => {
        const reader = rStream.getReader();
        const sendChunk = this.sendChunk;
        const decoder = this.decoder;

        return new ReadableStream({
          start () {
            let remaining = '';

            function read () { // handle each data chunk
              reader.read().then(({ done, value }) => {
                if (done) { // stream is done
                  if (remaining.length) {
                    sendChunk(subscriber, remaining);
                  }
                  return subscriber.complete();
                }

                remaining += decoder(value);

                let pos = 0;
                while ((pos = remaining.indexOf('\n')) > -1) {
                  // - 1 = remove the trailing , or ]
                  sendChunk(subscriber, remaining.slice(0, pos - 1));
                  // keep the rest because it may not be complete
                  remaining = remaining.slice(pos + 1, remaining.length);
                }

                read(); // keep reading until done
              });
            }

            read();
          }
        });
      }).catch((err) => { // this catches an issue with in the ^ .then
        subscriber.error(err);
        return subscriber.complete();
      });
    });
  }
};