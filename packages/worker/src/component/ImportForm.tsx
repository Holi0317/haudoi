export function ImportForm() {
  return (
    <form method="post" enctype="multipart/form-data">
      <label htmlFor="importFormat">Format: </label>
      <select id="importFormat" name="format">
        <option value="pocket">Pocket</option>
        <option value="raindrop">Raindrop.io</option>
      </select>

      <label htmlFor="importFile">Import File (CSV): </label>
      <input
        type="file"
        id="importFile"
        name="file"
        accept=".csv,text/csv"
        required
      />

      <input type="submit" value="Import" />
    </form>
  );
}
